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

	modelPB "github.com/instill-ai/protogen-go/model"
	"github.com/pkg/errors"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	serverAddress := flag.String("address", "localhost:8445", "the server address")
	testIamgePath := flag.String("test-image", "/Users/BochengYang/Downloads/drive-download-20220121T191023Z-001/eth_1.jpg", "the test image that are going to be sent")
	flag.Parse()

	conn, err := grpc.Dial(*serverAddress, grpc.WithTimeout(120*time.Second), grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	c := modelPB.NewModelClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	defer cancel()

	predictStream, err := c.PredictModelByUpload(ctx)
	defer predictStream.CloseSend()

	buf := make([]byte, 64*1024)
	firstChunk := true
	file, err := os.Open(*testIamgePath)

	for {
		n, errRead := file.Read(buf)
		if errRead != nil {
			if errRead == io.EOF {
				errRead = nil
				break
			}

			errRead = errors.Wrapf(errRead,
				"errored while copying from file to buf")
			return
		}
		if firstChunk {
			err = predictStream.Send(&modelPB.PredictModelRequest{
				Name:    "ensemble",
				Version: 1,
				Type:    1,
				Content: buf[:n],
			})
			firstChunk = false
		} else {
			err = predictStream.Send(&modelPB.PredictModelRequest{
				Content: buf[:n],
			})
		}
	}

	predictRes, err := predictStream.CloseAndRecv()
	if err != nil {
		log.Fatalf("error when triggering predict: %v", err)
	}

	predictResult, err := json.Marshal(predictRes)
	if err != nil {
		log.Fatalf("can not parse the predict output: %v", err)
	}

	log.Printf("Receive the inference result: %+v", predictResult)
}
