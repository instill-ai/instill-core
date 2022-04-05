// Package main implements a client for Model service.
// Package main implements a client for Model service.
package main

import (
	"context"
	"encoding/json"
	"flag"
	"io"
	"log"
	"os"
	"time"

	modelPB "github.com/instill-ai/protogen-go/model/v1alpha"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	serverAddress := flag.String("address", "localhost:8445", "the server address")
	testImagePath := flag.String("test-image", "./dog.jpg", "the test image that are going to be sent for prediction")
	modelName := flag.String("model-name", "", "the name of the model for creating pipeline's recipe")
	modelVersion := flag.Int("model-version", 1, "the version of the model for creating pipeline's recipe")
	flag.Parse()

	if *modelName == "" {
		log.Fatal("the model name is missing, you need to specify the model name for creating pipeline")
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*300)
	defer cancel()

	conn, err := grpc.DialContext(ctx, *serverAddress, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	c := modelPB.NewModelServiceClient(conn)

	predictStream, err := c.TriggerModelBinaryFileUpload(ctx)
	if err != nil {
		log.Fatalf("can not test model via predict endpoint: %v", err)
	}
	defer predictStream.CloseSend()

	buf := make([]byte, 64*1024)
	firstChunk := true
	file, err := os.Open(*testImagePath)
	if err != nil {
		log.Fatalf("can not open the file: %v", err)
	}
	finfo, _ := file.Stat()

	for {
		n, errRead := file.Read(buf)
		if errRead != nil {
			if errRead == io.EOF {
				errRead = nil
				break
			}

			log.Fatalf("there is an error while copying from file to buf: %s", errRead.Error())
		}
		if firstChunk {
			err = predictStream.Send(&modelPB.TriggerModelBinaryFileUploadRequest{
				Name:        *modelName,
				Version:     uint64(*modelVersion),
				FileLengths: []uint64{uint64(finfo.Size())},
				Bytes:       buf[:n],
			})
			if err != nil {
				log.Fatalf("failed to send data via stream: %v", err)
			}
			firstChunk = false
		} else {
			err = predictStream.Send(&modelPB.TriggerModelBinaryFileUploadRequest{
				Bytes: buf[:n],
			})
			if err != nil {
				log.Fatalf("failed to send data via stream: %v", err)
			}
		}
	}

	predictRes, err := predictStream.CloseAndRecv()
	if err != nil {
		log.Fatalf("there is an error when triggering predict: %v", err)
	}

	predictResult, err := json.Marshal(predictRes)
	if err != nil {
		log.Fatalf("can not parse the predict output: %v", err)
	}

	log.Printf("Receive the inference result: %v", string(predictResult))
}
