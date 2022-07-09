package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	pipelinePB "github.com/instill-ai/protogen-go/vdp/pipeline/v1alpha"
)

func main() {
	serverAddress := flag.String("address", "localhost:8081", "the server address")
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

	client := pipelinePB.NewPipelineServiceClient(conn)

	createPipelineReq := &pipelinePB.CreatePipelineRequest{
		Pipeline: &pipelinePB.Pipeline{
			Id:    *pipelineName,
			State: pipelinePB.Pipeline_STATE_ACTIVE,
			Recipe: &pipelinePB.Recipe{
				Source:         "source-connectors/source-http",
				ModelInstances: []string{fmt.Sprintf("models/%s/instances/latest", *modelName)},
				Destination:    "source-connectors/destination-http",
			},
		},
	}

	if res, err := client.CreatePipeline(ctx, createPipelineReq); err != nil {
		log.Fatalf("error when create pipeline: %v", err)
	} else {
		log.Printf("the pipeline has been created successfully: %v\n", res)
	}
}
