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
	flag.Parse()

	conn, err := grpc.Dial(*serverAddress, grpc.WithTimeout(120*time.Second), grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	c := modelPB.NewModelClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*60)
	defer cancel()

	uploadStream, err := c.CreateModelByUpload(ctx)
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
			log.Fatal("there is an error while copying from file to buf: %v", err)
		}
		if firstChunk {
			err = uploadStream.Send(&modelPB.CreateModelRequest{
				Description: "YoloV4 for object detection",
				Type:        "tensorrt",
				Framework:   "pytorch",
				Optimized:   false,
				Visibility:  "public",
				Content:     buf[:n],
			})
			firstChunk = false
		} else {
			err = uploadStream.Send(&modelPB.CreateModelRequest{
				Content: buf[:n],
			})
		}
	}

	uploadResp, err := uploadStream.CloseAndRecv()
	if err != nil {
		log.Fatal("errored while copying from file to buf: %v", err)
	}
	log.Printf("model has been created, the response is: %+v", uploadResp)

	for {
		time.Sleep(1000)
		model, err := c.GetModel(ctx, &modelPB.GetModelRequest{
			Name: "ensemble",
		})
		if err == nil && model.Name != "" {
			break
		}
	}

	_, err = c.UpdateModel(ctx, &modelPB.UpdateModelRequest{
		Model: &modelPB.UpdateModelInfo{
			Status: modelPB.UpdateModelInfo_ONLINE,
		},
		UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"status"}},
	})
	if err != nil {
		log.Fatal("can not make model online: %v", err)
	}
}
