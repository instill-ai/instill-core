package main

import (
	"context"
	"flag"
	"log"
	"time"

	pb "github.com/instill-ai/protogen-go/pipeline"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	serverAddress := flag.String("address", "localhost:8446", "the server address")
	pipelineName := flag.String("pipeline-name", "", "the name of the pipeline")
	modelName := flag.String("model-name", "", "the name of the model for creating pipeline's recipe")
	flag.Parse()

	if *pipelineName == "" {
		log.Fatal("you must specify the name of pipeline")
	}

	if *modelName == "" {
		log.Fatal("the model name is missing, you need to specify the model name for creating pipeline")
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*60)
	defer cancel()

	conn, err := grpc.DialContext(ctx, *serverAddress, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewPipelineClient(conn)

	createPipelineReq := &pb.CreatePipelineRequest{
		Name:        *pipelineName,
		Description: "Hello! My first pipeline",
		Active:      true,
		Recipe: &pb.Recipe{
			Source: &pb.Source{Type: "HTTP"},
			Model: []*pb.Model{
				{
					Name:    *modelName,
					Version: 1,
				},
			},
			Destination: &pb.Destination{Type: "HTTP"},
		},
	}

	if res, err := client.CreatePipeline(ctx, createPipelineReq); err != nil {
		log.Fatalf("error when create pipeline: %v", err)
	} else {
		log.Printf("the pipeline has been created successfully: %v\n", res)
	}
}
