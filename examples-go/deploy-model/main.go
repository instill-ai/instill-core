// Package main implements a client for Model service.
package main

import (
	"context"
	"flag"
	"io"
	"log"
	"os"
	"time"

	modelPB "github.com/instill-ai/protogen-go/model"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

func main() {
	serverAddress := flag.String("address", "localhost:8445", "the server address")
	modelPath := flag.String("model-path", "./examples-go/yolov4-onnx-cpu.zip", "the path of the zip compressed file for model")
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

	c := modelPB.NewModelClient(conn)

	uploadStream, err := c.CreateModelByUpload(ctx)
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
			err = uploadStream.Send(&modelPB.CreateModelRequest{
				Name:        *modelName,
				Description: "YoloV4 for object detection",
				CvTask:      modelPB.CVTask_DETECTION,
				Content:     buf[:n],
			})
			if err != nil {
				log.Fatalf("failed to send data via stream: %v", err)
			}
			firstChunk = false
		} else {
			err = uploadStream.Send(&modelPB.CreateModelRequest{
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
		model, err := c.GetModel(ctx, &modelPB.GetModelRequest{
			Name: *modelName,
		})
		if err == nil && model.Name != "" {
			break
		}
	}

	_, err = c.UpdateModel(ctx, &modelPB.UpdateModelRequest{
		Model: &modelPB.UpdateModelInfo{
			Name:    *modelName,
			Status:  modelPB.ModelStatus_ONLINE,
			Version: int32(*modelVersion),
		},
		UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"name", "status"}},
	})
	if err != nil {
		log.Fatalf("can not make model online: %v", err)
	}
}
