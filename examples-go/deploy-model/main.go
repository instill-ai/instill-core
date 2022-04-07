// Package main implements a client for Model service.
package main

import (
	"context"
	"flag"
	"io"
	"log"
	"os"
	"time"

	modelPB "github.com/instill-ai/protogen-go/model/v1alpha"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

func main() {
	serverAddress := flag.String("address", "localhost:8445", "the server address")
	mode := flag.String("mode", "local", "the mode to create a model which could be 'local' or 'github'")
	repoUrl := flag.String("url", "https://github.com/instill-ai/mobilenetv2.git", "the HTTP GitHub repository URL")
	repoBranch := flag.String("branch", "main", "the HTTP GitHub repository branch")
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

	c := modelPB.NewModelServiceClient(conn)

	switch *mode {
	case "github":
		uploadGithub, err := c.CreateModelByGitHub(ctx, &modelPB.CreateModelByGitHubRequest{
			Name:        *modelName,
			Description: "YoloV4 for object detection",
			Github: &modelPB.GitHub{
				RepoUrl: *repoUrl,
				GitRef: &modelPB.GitRef{
					Ref: &modelPB.GitRef_Branch{
						Branch: *repoBranch,
					},
				},
			},
		})
		if err != nil {
			log.Fatalf("there is an error while creating model: %v", err)
		}
		log.Printf("model has been created, the response is: %+v", uploadGithub)
	case "local":
		uploadStream, err := c.CreateModelBinaryFileUpload(ctx)
		if err != nil {
			log.Fatalf("can not create model: %v", err)
		}
		defer uploadStream.CloseSend() //nolint

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
					break
				}
				log.Fatalf("there is an error while copying from file to buf: %v", err)
			}
			if firstChunk {
				err = uploadStream.Send(&modelPB.CreateModelBinaryFileUploadRequest{
					Name:        *modelName,
					Description: "YoloV4 for object detection",
					Task:        modelPB.Model_TASK_DETECTION,
					Bytes:       buf[:n],
				})
				if err != nil {
					log.Fatalf("failed to send data via stream: %v", err)
				}
				firstChunk = false
			} else {
				err = uploadStream.Send(&modelPB.CreateModelBinaryFileUploadRequest{
					Bytes: buf[:n],
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
	default:
		log.Fatalf("Mode %v is not supported", mode)
	}

	for {
		time.Sleep(1000)
		res, err := c.GetModel(ctx, &modelPB.GetModelRequest{
			Name: *modelName,
		})
		if err == nil && res.Model.Name != "" {
			break
		}
	}

	_, err = c.UpdateModelVersion(ctx, &modelPB.UpdateModelVersionRequest{
		Name:    *modelName,
		Version: uint64(*modelVersion),
		VersionPatch: &modelPB.UpdateModelVersionPatch{
			Status: modelPB.ModelVersion_STATUS_ONLINE,
		},
		FieldMask: &fieldmaskpb.FieldMask{Paths: []string{"name", "status"}},
	})
	if err != nil {
		log.Fatalf("can not make model online: %v", err)
	}
}
