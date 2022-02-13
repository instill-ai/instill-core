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
	flag.Parse()

	conn, err := grpc.Dial(*serverAddress, grpc.WithTimeout(120*time.Second), grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewPipelineClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	createPipelineReq := &pb.CreatePipelineRequest{
		Name:        "hello-pipeline",
		Description: "Hello! My first pipeline",
		Active:      true,
		Recipe: &pb.Recipe{
			Source: &pb.Source{Type: "HTTP"},
			Model: []*pb.Model{
				{
					Name:    "yolov4",
					Version: 1,
				},
			},
			Destination: &pb.Destination{Type: "HTTP"},
		},
	}

	if res, err := client.CreatePipeline(ctx, createPipelineReq); err != nil {
		log.Fatalf("error when create pipeline: %v", err)
	} else {
		log.Printf("the pipeline created successfully: %v\n", res)
	}
}
