<h1 align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.svg" alt="Visual Data Preparation: open-source visual data ETL">
</h1>

<h4 align="center">
    <a href="https://www.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Website</a> |
    <a href="https://discord.gg/sevxWsqpGh">Community</a> |
    <a href="https://blog.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Blog</a>
</h4>

---

# Visual Data Preparation (VDP)  &nbsp; [![Twitter URL](https://img.shields.io/twitter/url?logo=twitter&style=social&url=https%3A%2F%2Fgithub.com%2Finstill-ai%2Fvdp)](https://twitter.com/intent/tweet?url=https%3A%2F%2Fgithub.com%2Finstill-ai%2Fvdp&via=instill_tech&text=Build%20end-to-end%20visual%20data%20processing%20pipelines%20with%20VDP%2C%2010x%20faster.&hashtags=ETL%2Cvdp%2Cdata%2Cai%2Cml%2Copensource)

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/vdp?color=blue&include_prereleases)](https://github.com/instill-ai/vdp/releases)
[![License Apache-2.0](https://img.shields.io/crates/l/ap)](https://github.com/instill-ai/vdp/blob/main/LICENSE)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=community&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)

**Visual Data Preparation (VDP)** is an open-source visual data ETL tool to streamline the end-to-end visual data processing pipeline:

1. **Extract** unstructured visual data from pre-built data sources such as cloud/on-prem storage, or IoT devices

2. **Transform** it into analysable structured data by Vision AI models

3. **Load** the transformed data into warehouses, applications, or other destinations

## Highlights

- 🚀 **The fastest way to build end-to-end visual data pipelines** - building a pipeline is like assembling LEGO blocks

- ⚡️ **High-performing backends** implemented in Go with [Triton Inference Server](https://github.com/triton-inference-server/server) for unleashing the full power of NVIDIA GPU architecture (e.g., concurrency, scheduler, batcher) supporting TensorRT, PyTorch, TensorFlow, ONNX, Python and more.

- 🖱️ **One-click import & deploy ML/DL models** from popular GitHub, [Hugging Face](https://huggingface.co) or cloud storage managed by version control tools like [DVC](https://dvc.org) or [ArtiVC](https://artivc.io)

- 📦 **Standardised vision task** structured output formats to streamline with data warehouse

- 🔌 **Pre-built ETL data connectors** for extensive data access integrated with [Airbyte](https://github.com/airbytehq/airbyte)

- 🪢 **Build pipelines for diverse scenarios** - **SYNC** for real-time inference and **ASYNC** for on-demand workload

- 🧁 **Scalable API-first microservice design for great developer experience** - seamless integration to modern data stack at any scale

- 🤠 **Build for every Vision AI and Data practitioner** - The no-/low-code interface helps take off your AI Researcher/AI Engineer/Data Engineer/Data Scientist hat and *put on the all-rounder hat* to deliver more with VDP

## Online demos

Want to showcase your ML/DL models? We also offer fully-managed VDP on Instill Cloud. Please [sign up the form](https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) and we will reach out to you.

#### Object Detection: YOLOv4 vs. YOLOv7
We use VDP to import the official [YOLOv4](https://github.com/AlexeyAB/darknet) and [YOLOv7](https://github.com/WongKinYiu/yolov7) models pre-trained with only [MS-COCO](https://cocodataset.org) dataset. VDP instantly gives us the endpoints to perform inference. Try out the live demo [![VDP Demo](https://img.shields.io/badge/VDP-YOLOv4%20vs%20YOLOv7%20Demo-blue)](https://demo.instill.tech/yolov4-vs-yolov7)

## Why we build VDP

Before we started to build VDP, we had fought with streaming large volume data (billions of images a day!) to automate vision tasks using deep learning-based computer vision, sweating blood to build everything from scratch.

We've learned that model serving for an effective end-to-end data flow concerns not only **high throughput** and **low latency** but also **cost efficiency**, and these criteria are non-trivial to achieve altogether. Nonetheless, we had successfully built a battle-proven model serving system in-house and have the system run in production for years.

What we had built can actually be modularised into working components to be generalised to a broader spectrum of vision tasks and industry sectors. We think it's about time to share the experiences and to extend the system to make Vision AI more accessible to everyone.

The goal of VDP is to seamlessly bring Vision AI into the modern data stack with a standardised framework. Check our blog post [Missing piece in modern data stack: visual data preparation](https://blog.instill.tech/visual-data-preparation/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) on how this tool can make a significant impact on unstructured visual data processing across different stakeholders.

## How VDP works

The core concept of VDP is **_pipeline_**. A pipeline is an end-to-end workflow that automates a sequence of tasks to process visual data. Each pipeline is defined and formed by a _recipe_ that contains three components:
1. **source**: where the pipeline starts. It connects the source of image and video data to be processed.

2. **model instances**: a series of deployed Vision AI models to process the ingested visual data in parallel and generate structured outputs

3. **destination**: where to send the structured outputs

Based on [the mode of a pipeline](docs/pipeline-mode.md), it will extract and process the visual data, and send the outputs to the destination every time the trigger event occurs.

Check out the pipeline recipe example below. This recipe defines that the pipeline accepts HTTP requests, processes the request data using YOLOv4 model, and returns the outputs in HTTP responses. With this simple configuration, now we have a pipeline equivalent to a powerful HTTP prediction server 🚀.
```JSON
{
    "recipe": {
        "source": "source-connectors/source-http",
        "model_instances": [
            "models/yolov4/instances/v1.0-cpu"
        ],
        "destination": "destination-connectors/destination-http"
    }
}
```

> **Note**
>
> We use **connector** as a general term to represent data source and destination. Please find the supported connectors [here](docs/connector.md).

### Guidance philosophy
VDP is built with open heart and we expect VDP to be exposed to more MLOps integrations. It is implemented with microservice and API-first design principle. Instead of building all components from scratch, we've decided to adopt sophisticated open-source tools:

- [Triton Inference Server](https://github.com/triton-inference-server/server) for high-performance model serving

- [Temporal](https://github.com/temporalio/temporal) for a reliable, durable and scalable workflow engine

- [Airbyte](https://github.com/airbytehq/airbyte) for abundant destination connectors

We hope VDP can also enrich the open-source communities in a way to bring more practical use cases in unstructured visual data processing.

## Prerequisites

- **macOS or Linux** - VDP works on macOS or Linux, but does not support Windows.

- **Docker and Docker Compose** - VDP uses Docker Compose (compose file version: `3.9`) to run all services at local. Please install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using VDP.

## Quick start

Execute the following commands to start pre-built images with all the dependencies:

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp

# Launch all services
$ make all
```

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000!

Here is a [step-by-step guide](docs/quickstart.md) to build your first pipeline.

> **Warning**
>
> The image of model-backend (~2GB) and Triton Inference Server (~11GB) can take a while to pull, but this should be an one-time effort at the first setup.

**Shut down VDP**

To shut down all running services:
```
$ make down
```

<!-- ### Low-code examples -->

<!-- Based on the API-first design, the use of VDO should be as simple as making API calls. A number of code examples can be found in the `examples/` folder. -->

<!-- ### Create a pipeline with your own models -->
<!-- Please follow the [guideline](docs/model.md#prepare-your-own-model-to-deploy-on-vdp) to build pipelines with your own model. -->

## Model Hub

We curate a list of ready-to-use models for VDP. These models are from different sources and have been tested by our team. Want to contribute a new model? Please create an issue, we are happy to test and add it to the list 👐.

| Model                                                                                                                                               | Task                 | Sources                                                                                                            | Framework | CPU | GPU | Notes |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------ | --------- | --- | --- | ----- |
| [MobileNet v2](https://github.com/onnx/models/tree/main/vision/classification/mobilenet)                                                            | Image classification | [GitHub](https://github.com/instill-ai/model-mobilenetv2)                                                          | ONNX      | ✅   | ✅   |       |
| [YOLOv4](https://github.com/AlexeyAB/darknet)                                                                                                       | Object detection     | [GitHub](https://github.com/instill-ai/model-yolov4), [GitHub-DVC](https://github.com/instill-ai/model-yolov4-dvc) | ONNX      | ✅   | ✅   |       |
| [YOLOv7](https://github.com/WongKinYiu/yolov7)                                                                                                      | Object detection     | [GitHub](https://github.com/instill-ai/model-yolov7), [GitHub-DVC](https://github.com/instill-ai/model-yolov7-dvc) | ONNX      | ✅   | ✅   |       |
| [Detectron2 Keypoint R-CNN R50-FPN](https://github.com/facebookresearch/detectron2/blob/main/configs/COCO-Keypoints/keypoint_rcnn_R_50_FPN_1x.yaml) | Keypoint detection   | [GitHub](https://github.com/instill-ai/model-keypoint-detection), [GitHub-DVC](https://github.com/instill-ai/model-keypoint-detection-dvc)                                                 | PyTorch   | ✅   | ❌   |       |

Note: The `GitHub-DVC` source in the table means importing a model into VDP from a GitHub repository that uses [DVC](https://dvc.org) to manage large files.

## Documentation

📔 **Documentation & tutorials are coming soon!**

📘 **API Reference**

The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the VDP APIs. The genuine protobuf documentation can be found in our [Buf Scheme Registry (BSR)](https://buf.build/instill-ai/protobufs).

For the OpenAPI documentation, access http://localhost:3001 after `make all`, or simply run `make doc`.

## Contribution

We love contribution to VDP in any forms:

- Please refer to the [guide](docs/development.md) for local development.

- Please open a topic in the repository [Discussions](https://github.com/instill-ai/vdp/discussions) for any feature requests.

- Please open issues for bug report in the repository

  - [vdp](https://github.com/instill-ai/vdp) for general issues;

  - [pipeline-backend](https://github.com/instill-ai/pipeline-backend), [connector-backend](https://github.com/instill-ai/connector-backend), [model-backend](https://github.com/instill-ai/model-backend), [mgmt-backend](https://github.com/instill-ai/mgmt-backend), etc., for backend-specific issues.

- Please refer to the [VDP project board](https://github.com/orgs/instill-ai/projects/5) to track progress.

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) - bug reports, feature requests, project discussions and contributions

- [Discord](https://discord.gg/sevxWsqpGh) - live discussion with the community and our team

- [Newsletter](https://www.instill.tech/newsletter/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) & [Twitter](https://twitter.com/instill_tech) - get the latest updates

If you are interested in hosting service of VDP, we've started signing up users to our private alpha. [Get early access](https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) and we'll contact you when we're ready.

## License

See the [LICENSE](./LICENSE) file for licensing information.
