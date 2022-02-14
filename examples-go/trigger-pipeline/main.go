package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"io"
	"log"
	"os"
	"time"

	pb "github.com/instill-ai/protogen-go/pipeline"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	serverAddress := flag.String("address", "localhost:8446", "the server address")
	pipelineName := flag.String("pipeline-name", "", "the name of the pipeline you've created")
	testIamgePath := flag.String("test-image", "./dog.jpg", "the test image that are going to be sent")
	flag.Parse()

	if *pipelineName == "" {
		log.Fatal("you must specify the name of pipeline")
	}

	conn, err := grpc.Dial(*serverAddress, grpc.WithTimeout(120*time.Second), grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewPipelineClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	file, err := os.Open(*testIamgePath)
	if err != nil {
		log.Fatal("cannot open image file: ", err)
	}
	defer file.Close()

	stream, err := client.TriggerPipelineByUpload(ctx)
	if err != nil {
		log.Fatal("cannot upload image: ", err)
	}

	req := &pb.TriggerPipelineRequest{
		Name: *pipelineName,
	}

	err = stream.Send(req)
	if err != nil {
		log.Fatal("cannot send image info to server: ", err, stream.RecvMsg(nil))
	}

	reader := bufio.NewReader(file)
	buffer := make([]byte, 1024)

	for {
		n, err := reader.Read(buffer)
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal("cannot read chunk to buffer: ", err)
		}

		contents := []*pb.TriggerPipelineContent{}
		contents = append(contents, &pb.TriggerPipelineContent{Chunk: buffer[:n]})

		req := &pb.TriggerPipelineRequest{
			Contents: contents,
		}

		err = stream.Send(req)
		if err != nil {
			log.Fatal("cannot send chunk to server: ", err, stream.RecvMsg(nil))
		}
	}

	res, err := stream.CloseAndRecv()
	if err != nil {
		log.Fatalf("error when triggering predict: %v", err)
	}

	obj, err := json.Marshal(res)
	if err != nil {
		log.Fatalf("can not parse the predict output: %v", err)
	}

	log.Printf("Receive the inference result: %+v", string(obj))
}
