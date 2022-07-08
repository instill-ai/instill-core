// Package main implements a client for Model service.
package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	modelPB "github.com/instill-ai/protogen-go/vdp/model/v1alpha"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	serverAddress := flag.String("address", "localhost:8083", "the server address")
	modelPath := flag.String("model-path", "./examples-go/yolov4-onnx-cpu.zip", "the path of the zip compressed file for model")
	modelName := flag.String("model-name", "", "the name of the model for creating pipeline's recipe")
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

	uploadStream, err := c.CreateModelBinaryFileUpload(ctx)
	if err != nil {
		log.Fatalf("can not create model: %v", err)
	}
	defer uploadStream.CloseSend()

	buf := make([]byte, 64*1024)
	firstChunk := true
	file, err := os.Open(*modelPath)
	if err != nil {
		log.Fatalf("failed to open file: %v", err)
	}
	defer file.Close()

	for {
		n, err := file.Read(buf)
		if err != nil {
			if err == io.EOF {
				err = nil
				break
			}
			log.Fatalf("there is an error while copying from file to buf: %v", err)
		}

		if firstChunk {
			des := "YoloV4 for object detection"
			err = uploadStream.Send(&modelPB.CreateModelBinaryFileUploadRequest{
				Model: &modelPB.Model{
					Id:              *modelName,
					Description:     &des,
					ModelDefinition: "model-definitions/local",
				},
				Content: buf[:n],
			})
			firstChunk = false
			if err != nil {
				log.Fatalf("failed to send data via stream: %v", err)
			}
		} else {
			err = uploadStream.Send(&modelPB.CreateModelBinaryFileUploadRequest{
				Content: buf[:n],
			})

			if err != nil {
				log.Fatalf("failed to send data via stream: %v", err)
			}
		}

	}

	uploadResp, err := uploadStream.CloseAndRecv()
	if err != nil {
		log.Fatalf("there is an error while creating model: %v", err)
	}
	log.Printf("model has been created, the response is: %+v", uploadResp)

	for {
		time.Sleep(1000)
		res, err := c.GetModel(ctx, &modelPB.GetModelRequest{
			Name: fmt.Sprintf("models/%s", *modelName),
		})
		if err == nil && res.Model.Name != "" {
			break
		}
	}

	_, err = c.DeployModelInstance(ctx, &modelPB.DeployModelInstanceRequest{
		Name: fmt.Sprintf("models/%v/instances/latest", *modelName),
	})

	if err != nil {
		log.Fatalf("can not make model online: %v", err)
	}
}
