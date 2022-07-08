# Examples

We provide sample codes on how to build and trigger an object detection pipeline. Run it with the local VDP:

```bash
# Download a YOLOv4 ONNX model for object detection task (GPU not required)
$ curl -o yolov4-onnx-cpu.zip https://artifacts.instill.tech/vdp/sample-models/yolov4-onnx-cpu.zip

# [optional] Download a test image or use your own images
$ curl -o dog.jpg https://artifacts.instill.tech/dog.jpg

# Deploy the model
$ go run deploy-model/main.go --model-path yolov4-onnx-cpu.zip --model-name yolov4

# Test the model
$ go run test-model/main.go --model-name yolov4 --test-image dog.jpg

# Create a HTTP source connector and a HTTP destination connector
$ go run create-connector/main.go 

# Create an object detection pipeline
$ go run create-pipeline/main.go --pipeline-name hello-pipeline --model-name yolov4

# Trigger the pipeline by using the same test image
$ go run trigger-pipeline/main.go --pipeline-name hello-pipeline --test-image dog.jpg
```
