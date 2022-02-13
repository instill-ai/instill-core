<h1 align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/visual-data-preparation.png" alt="Instill AI - Visual Data Preparation Made for All" />
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
3. Load the structured data into warehouses, applications or other destinations.

The goal of VDP is to seamlessly bring Vision AI into modern data stack with a standardised framework. Check our blog post [Missing piece in modern data stack: visual data preparation](https://blog.instill.tech/visual-data-preparation/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) on how this tool is proposed to streamline unstructured visual data processing across different stakeholders.

### Table of contents <!-- omit in toc -->
- [How VDP works](#how-vdp-works)
- [Quick start](#quick-start)
  - [Download and run VDP locally](#download-and-run-vdp-locally)
  - [Run the samples to trigger an object detection pipeline](#run-the-samples-to-trigger-an-object-detection-pipeline)
  - [Create a pipeline with your own model](#create-a-pipeline-with-your-own-model)
- [Community support](#community-support)
- [Documentation](#documentation)
  - [API reference](#api-reference)
  - [Build docker](#build-docker)
- [License](#license)

## How VDP works

The core concept of VDP is _pipeline_. A pipeline is an end-to-end workflow that automates end-to-end visual data processing. Each pipeline consists of three ordered components:
1. _data source_: where the pipeline starts. It connects the source of image and video data to be processed and has a trigger mechanism for initiating the pipeline execution.
2. _model_: a deployed Vision AI model to process the ingested visual data and generate structured outputs
3. _data destination_: where to send the structured outputs

Based on the trigger mechanism of the data source, when you trigger a pipeline, it will ingest and process the visual data, send the outputs to the destination every time the trigger event occurs.

We also use _data connector_ as a general term to represent data source or data destination. Here is a list of data connectors that VDP supports.

We will continue adding new connectors to VDP. If you want to make a request, feel free to create a issue and describe your use case.


## Quick start

### Download and run VDP locally

Execute the following commands to start pre-built images with all the dependencies
```bash
mkdir conda-pack
curl -o conda-pack/python-3-8.tar.gz https://artifacts.instill.tech/vdp/conda-pack/python-3-8.tar.gz

git clone https://github.com/instill-ai/vdp.git
docker-compose up
```

### Run the samples to trigger an object detection pipeline
We provide sample codes on how to build and trigger an object detection pipeline. Run it with the local VDP.

```bash
cd examples-go

# Download a YOLOv4 ONNX model for object detection task (GPU not required)
curl -o yolov4-onnx-cpu.zip https://artifacts.instill.tech/vdp/sample-models/yolov4-onnx-cpu.zip

# [optional] Download a test image or use your own images
curl -o dog.jpg https://artifacts.instill.tech/dog.jpg

# Deploy the model
go run deploy-model/main.go --model-path yolov4-onnx-cpu.zip

# Test the model
go run test-model/main.go --test-image dog.jpg

# Create an object detection pipeline
go run create-pipeline/main.go

# Trigger the pipeline by using same test image
go run trigger-pipeline/main.go --test-image dog.jpg
```

### Create a pipeline with your own model

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) (bug reports, feature requests, project discussions and contributions)
- [Discord](https://discord.gg/sevxWsqpGh) (live discussion with the community and the Instill AI Team)

## Documentation

### API reference

### Build docker

You can build a development Docker image using:
```bash
make docker
```

## License

See the [LICENSE](https://github.com/instill-ai/vdp/blob/main/LICENSE) file for licensing information.
