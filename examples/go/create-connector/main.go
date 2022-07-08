package main

import (
	"context"
	"flag"
	"log"
	"time"

	ct "github.com/instill-ai/protogen-go/vdp/connector/v1alpha"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	serverAddress := flag.String("address", "localhost:8082", "the server address")
	flag.Parse()

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*60)
	defer cancel()

	conn, err := grpc.DialContext(ctx, *serverAddress, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	client := ct.NewConnectorServiceClient(conn)

	createSourceConnectorReq := &ct.CreateSourceConnectorRequest{
		SourceConnector: &ct.SourceConnector{
			Id:                        "source-http",
			SourceConnectorDefinition: "source-connectors/source-http",
			Connector: &ct.Connector{
				Configuration: "{}",
			},
		},
	}

	if res, err := client.CreateSourceConnector(ctx, createSourceConnectorReq); err != nil {
		log.Fatalf("error when create source connector: %v", err)
	} else {
		log.Printf("the source connector has been created successfully: %v\n", res)
	}

	createDestinationConnectorReq := &ct.CreateDestinationConnectorRequest{
		DestinationConnector: &ct.DestinationConnector{
			Id:                             "destination-http",
			DestinationConnectorDefinition: "source-connectors/destination-http",
			Connector: &ct.Connector{
				Configuration: "{}",
			},
		},
	}

	if res, err := client.CreateDestinationConnector(ctx, createDestinationConnectorReq); err != nil {
		log.Fatalf("error when create destination connector: %v", err)
	} else {
		log.Printf("the destination connector has been created successfully: %v\n", res)
	}
}
