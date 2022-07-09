package main

import (
	"context"
	"flag"
	"log"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/protobuf/types/known/structpb"

	connectorPB "github.com/instill-ai/protogen-go/vdp/connector/v1alpha"
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

	client := connectorPB.NewConnectorServiceClient(conn)

	createSourceConnectorReq := &connectorPB.CreateSourceConnectorRequest{
		SourceConnector: &connectorPB.SourceConnector{
			Id:                        "source-http",
			SourceConnectorDefinition: "source-connectors/source-http",
			Connector: &connectorPB.Connector{
				Configuration: &structpb.Struct{},
			},
		},
	}

	if res, err := client.CreateSourceConnector(ctx, createSourceConnectorReq); err != nil {
		log.Fatalf("error when create source connector: %v", err)
	} else {
		log.Printf("the source connector has been created successfully: %v\n", res)
	}

	createDestinationConnectorReq := &connectorPB.CreateDestinationConnectorRequest{
		DestinationConnector: &connectorPB.DestinationConnector{
			Id:                             "destination-http",
			DestinationConnectorDefinition: "source-connectors/destination-http",
			Connector: &connectorPB.Connector{
				Configuration: &structpb.Struct{},
			},
		},
	}

	if res, err := client.CreateDestinationConnector(ctx, createDestinationConnectorReq); err != nil {
		log.Fatalf("error when create destination connector: %v", err)
	} else {
		log.Printf("the destination connector has been created successfully: %v\n", res)
	}
}
