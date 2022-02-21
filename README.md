<h1 align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.png" alt="Instill AI - Visual Data Preparation Made for All" />
</h1>

<h4 align="center">
    <a href="https://www.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Website</a> |
    <a href="https://discord.gg/sevxWsqpGh">Community</a> |
    <a href="https://blog.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Blog</a>
</h4>

<h4 align="center">
    <p>
        <a href="https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme"><strong>Get Early Access</strong></a>
    <p>
</h4>

---

**Visual Data Preparation (VDP)** is an open-source tool to streamline the end-to-end visual data processing pipeline:

1. Ingest unstructured visual data from data sources such as data lakes or IoT devices;
2. Transform visual data to meaningful structured data representations by Vision AI models;
3. Load the structured data into warehouses, applications, or other destinations.

The goal of VDP is to seamlessly bring Vision AI into the modern data stack with a standardised framework. Check our blog post [Missing piece in modern data stack: visual data preparation](https://blog.instill.tech/visual-data-preparation/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) on how this tool is proposed to streamline unstructured visual data processing across different stakeholders.

### Table of contents <!-- omit in toc -->
- [How VDP works](#how-vdp-works)
- [Quick start](#quick-start)
  - [Download and run VDP locally](#download-and-run-vdp-locally)
  - [Run the samples to trigger an object detection pipeline](#run-the-samples-to-trigger-an-object-detection-pipeline)
  - [Create a pipeline with your own models](#create-a-pipeline-with-your-own-models)
  - [Clean up](#clean-up)
- [Documentation](#documentation)
- [Local development](#local-development)
- [Community support](#community-support)
- [License](#license)

> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

## How VDP works

The core concept of VDP is _pipeline_. A pipeline is an end-to-end workflow that automates end-to-end visual data processing. Each pipeline consists of three ordered components:
1. **data source**: where the pipeline starts. It connects the source of image and video data to be processed.
2. **model**: a deployed Vision AI model to process the ingested visual data and generate structured outputs
3. **data destination**: where to send the structured outputs

Based on [the mode of a pipeline](docs/pipeline-mode.md), it will ingest and process the visual data, send the outputs to the destination every time the trigger event occurs.

We use **data connector** as a general term to represent data source and data destination. Please find the supported data connectors [here](docs/connector.md).

## Quick start

### Download and run VDP locally

Execute the following commands to start pre-built images with all the dependencies:

```bash
git clone https://github.com/instill-ai/vdp.git

make all
```
Note that this may take a while due to the big size of the Triton server image.

### Run the samples to trigger an object detection pipeline
We provide sample codes on how to build and trigger an object detection pipeline. Run it with the local VDP:

```bash
cd examples-go

# Download a YOLOv4 ONNX model for object detection task (GPU not required)
curl -o yolov4-onnx-cpu.zip https://artifacts.instill.tech/vdp/sample-models/yolov4-onnx-cpu.zip

# [optional] Download a test image or use your own images
curl -o dog.jpg https://artifacts.instill.tech/dog.jpg

# Deploy the model
go run deploy-model/main.go --model-path yolov4-onnx-cpu.zip --model-name yolov4

# Test the model
go run test-model/main.go --model-name yolov4 --test-image dog.jpg

# Create an object detection pipeline
go run create-pipeline/main.go --pipeline-name hello-pipeline --model-name yolov4

# Trigger the pipeline by using the same test image
go run trigger-pipeline/main.go --pipeline-name hello-pipeline --test-image dog.jpg
```

### Create a pipeline with your own models
Please follow the guideline "[Prepare your own model to deploy on VDP
](docs/model.md#prepare-your-own-model-to-deploy-on-vdp)". Based on the above sample codes, you can deploy a prepared model and create your own pipeline.

### Clean up
To clean up all running services:
```
make prune
```

## Documentation

The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the VDP APIs. To view the generated OpenAPI spec, run
```bash
make doc
```
, and now visit http://localhost:3000.

## Local development

You can build a development Docker image using:
```bash
make build
```

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) (bug reports, feature requests, project discussions and contributions)
- [Discord](https://discord.gg/sevxWsqpGh) (live discussion with the community and the Instill AI Team)

## License

See the [LICENSE](https://github.com/instill-ai/vdp/blob/main/LICENSE) file for licensing information.
