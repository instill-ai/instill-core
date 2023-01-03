<h1 align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.svg" alt="Versatile Data Pipeline: open-source unstructured data ETL">
</h1>

<h4 align="center">
    <a href="https://www.instill.tech/career?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">We're hiring 🚀</a>
</h4>

<h4 align="center">
    <a href="https://www.instill.tech/docs?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Doc</a> |
    <a href="https://www.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Website</a> |
    <a href="https://discord.gg/sevxWsqpGh">Community</a> |
    <a href="https://blog.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Blog</a>
</h4>

---

# Versatile Data Pipeline (VDP)  &nbsp; [![Twitter URL](https://img.shields.io/twitter/url?logo=twitter&style=social&url=https%3A%2F%2Fgithub.com%2Finstill-ai%2Fvdp)](https://twitter.com/intent/tweet?url=https%3A%2F%2Fgithub.com%2Finstill-ai%2Fvdp&via=instill_tech&text=Build%20end-to-end%20unstructured%20data%20processing%20pipelines%20with%20VDP%2C%2010x%20faster.&hashtags=ETL%2Cvdp%2Cdata%2Cai%2Cml%2Copensource)

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/vdp?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/vdp/releases)
[![License Apache-2.0](https://img.shields.io/crates/l/ap?label=License&color=blue&logo=apache)](https://github.com/instill-ai/vdp/blob/main/LICENSE)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Community&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Pipeline-backend Docker pull](https://img.shields.io/docker/pulls/instill/pipeline-backend?label=Docker&logo=docker&logoColor=fff)](https://hub.docker.com/u/instill)
[![Integration test](https://img.shields.io/github/actions/workflow/status/instill-ai/vdp/integration-test.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/vdp/actions/workflows/integration-test.yml?branch=main&event=push)
[![Documentation deployment workflow](https://img.shields.io/github/actions/workflow/status/instill-ai/instill.tech/release.yml?branch=main&label=Docs&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDAuNzUwMDA0QzAgMC41NTEwOTEgMC4wNzkwMTc2IDAuMzYwMzI2IDAuMjE5NjcgMC4yMTk2NzRDMC4zNjAzMjIgMC4wNzkwMjEzIDAuNTUxMDg4IDMuNjgxOTFlLTA2IDAuNzUgMy42ODE5MWUtMDZINS4wMDNDNi4yMyAzLjY4MTkxZS0wNiA3LjMyIDAuNTkwMDA0IDguMDAzIDEuNTAxQzguMzUyMTggMS4wMzQzMyA4LjgwNTQ4IDAuNjU1NjI3IDkuMzI2ODMgMC4zOTUwNDJDOS44NDgxNyAwLjEzNDQ1NiAxMC40MjMyIC0wLjAwMDgxMzY0NiAxMS4wMDYgMy42ODE5MWUtMDZIMTUuMjUxQzE1LjQ0OTkgMy42ODE5MWUtMDYgMTUuNjQwNyAwLjA3OTAyMTMgMTUuNzgxMyAwLjIxOTY3NEMxNS45MjIgMC4zNjAzMjYgMTYuMDAxIDAuNTUxMDkxIDE2LjAwMSAwLjc1MDAwNFYxMS4yNUMxNi4wMDEgMTEuNDQ4OSAxNS45MjIgMTEuNjM5NyAxNS43ODEzIDExLjc4MDNDMTUuNjQwNyAxMS45MjEgMTUuNDQ5OSAxMiAxNS4yNTEgMTJIMTAuNzQ0QzEwLjQ0ODUgMTIgMTAuMTU1OSAxMi4wNTgyIDkuODgyOTYgMTIuMTcxM0M5LjYwOTk3IDEyLjI4NDMgOS4zNjE5MyAxMi40NTAxIDkuMTUzIDEyLjY1OUw4LjUzMSAxMy4yOEM4LjM5MDM3IDEzLjQyMDUgOC4xOTk3NSAxMy40OTkzIDguMDAxIDEzLjQ5OTNDNy44MDIyNSAxMy40OTkzIDcuNjExNjMgMTMuNDIwNSA3LjQ3MSAxMy4yOEw2Ljg0OSAxMi42NTlDNi42NDAwNyAxMi40NTAxIDYuMzkyMDMgMTIuMjg0MyA2LjExOTA0IDEyLjE3MTNDNS44NDYwNiAxMi4wNTgyIDUuNTUzNDggMTIgNS4yNTggMTJIMC43NUMwLjU1MTA4OCAxMiAwLjM2MDMyMiAxMS45MjEgMC4yMTk2NyAxMS43ODAzQzAuMDc5MDE3NiAxMS42Mzk3IDAgMTEuNDQ4OSAwIDExLjI1TDAgMC43NTAwMDRaTTguNzU1IDMuNzVDOC43NTUgMy4xNTMyNyA4Ljk5MjA1IDIuNTgwOTcgOS40MTQwMSAyLjE1OTAxQzkuODM1OTcgMS43MzcwNiAxMC40MDgzIDEuNSAxMS4wMDUgMS41SDE0LjVWMTAuNUgxMC43NDNDMTAuMDMzIDEwLjUgOS4zNDMgMTAuNzAxIDguNzUxIDExLjA3Mkw4Ljc1NSAzLjc1VjMuNzVaTTcuMjUxIDExLjA3NEw3LjI1NSA2LjAwMUw3LjI1MyAzLjc0OEM3LjI1MjQ3IDMuMTUxNjEgNy4wMTUxOCAyLjU3OTgzIDYuNTkzMjggMi4xNTgzMUM2LjE3MTM4IDEuNzM2NzggNS41OTkzOSAxLjUgNS4wMDMgMS41SDEuNVYxMC41SDUuMjU3QzUuOTYyNDIgMTAuNSA2LjY1MzU1IDEwLjY5ODkgNy4yNTEgMTEuMDc0VjExLjA3NFoiIGZpbGw9IndoaXRlIi8+Cjwvc3ZnPgo=)](https://github.com/instill-ai/instill.tech/actions/workflows/deploy-prod.yml)


**Versatile Data Pipeline (VDP)** is an open-source unstructured data ETL tool to streamline the end-to-end unstructured data processing pipeline:

- **Extract** unstructured data from pre-built data sources such as cloud/on-prem storage, or IoT devices

- **Transform** it into analysable or meaningful data representations by AI models

- **Load** the transformed data into warehouses, applications, or other destinations

![VDP Concept](https://artifacts.instill.tech/imgs/vdp-concept.png?id=1)

## Highlights

- 🚀 **[The fastest way to build end-to-end unstructured data pipelines](https://www.instill.tech/docs/core-concepts/pipeline)** - building a pipeline is like assembling LEGO blocks

- ⚡️ **[High-performing backends](https://www.instill.tech/docs/prepare-models/overview)** implemented in Go with Triton Inference Server for unleashing the full power of NVIDIA GPU architecture (e.g., concurrency, scheduler, batcher) supporting TensorRT, PyTorch, TensorFlow, ONNX, Python and more.

- 🖱️ **[One-click import & deploy ML/DL models](https://www.instill.tech/docs/import-models/overview)** from GitHub, Hugging Face or cloud storage managed by version control tools like DVC or ArtiVC

- 📦 **[Standardised AI Task](https://www.instill.tech/docs/core-concepts/ai-task)** output formats to streamline data integration or analysis

- 🔌 **[Pre-built ETL data connectors](https://www.instill.tech/docs/core-concepts/connector)** for extensive data access integrated with Airbyte

- 🪢 **[Build pipelines for diverse scenarios](https://www.instill.tech/docs/core-concepts/pipeline#mode)** - **SYNC** mode for real-time inference and **ASYNC** mode for on-demand workload

- 🧁 **[Scalable API-first microservice design for great developer experience](https://www.instill.tech/docs/start-here/faq#tech)** - seamless integration to modern data stack at any scale

- 🤠 **[Built for every AI and Data practitioner](https://www.instill.tech/docs/start-here/faq#essentials)** - The no-/low-code interface helps take off your AI Researcher/AI Engineer/Data Engineer/Data Scientist hat and *put on the all-rounder hat* to deliver more with VDP

## Online demos

An online demo VDP instance has been provisioned, in which you can directly play around the basic features in its Console via https://demo.instill.tech and the API (e.g., https://demo.instill.tech/v1alpha/pipelines).

A number of applications that you can possibly use VDP to quickly achieve are showcased below:

- [![Object Detection Demo](https://img.shields.io/badge/Object%20Detection-%20YOLOv4%20vs%20YOLOv7-pink)](https://demo.instill.tech/yolov4-vs-yolov7)

Want to showcase your ML/DL models? We offer fully-managed VDP on Instill Cloud. Please [sign up the form](https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) and we will reach out to you.

## Prerequisites

- **macOS or Linux** - VDP works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - VDP uses Docker Compose (compose file version: `3.9`) to run all services at local. Please install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using VDP.

## Quick start

Execute the following commands to start pre-built images with all the dependencies:

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp

# Launch all services
$ make all
```

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000!

![VDO Console](https://artifacts.instill.tech/imgs/vdp-console.png?)

Jump right in
- [Build your first SYNC pipeline with no-/low-code](https://www.instill.tech/docs/tutorials/build-a-sync-cls-pipeline/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme)
- [Build your first ASYNC pipeline with no-/low-code](https://www.instill.tech/docs/tutorials/build-an-async-det-pipeline/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme)

> **Note**
>
> The image of model-backend (~2GB) and Triton Inference Server (~11GB) can take a while to pull, but this should be an one-time effort at the first setup.

**Shut down VDP**

To shut down all running services:
```
$ make down
```
### Guidance philosophy
VDP is built with open heart and we expect VDP to be exposed to more MLOps integrations. It is implemented with microservice and API-first design principle. Instead of building all components from scratch, we've decided to adopt sophisticated open-source tools:

- [Triton Inference Server](https://github.com/triton-inference-server/server) for high-performance model serving

- [Temporal](https://github.com/temporalio/temporal) for a reliable, durable and scalable workflow engine

- [Airbyte](https://github.com/airbytehq/airbyte) for abundant destination connectors

We hope VDP can also enrich the open-source communities in a way to bring more practical use cases in unstructured data processing.

## Documentation

📔 **Documentation**


 Check out the [documentation & tutorials](https://www.instill.tech/docs?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) to learn VDP!

📘 **API Reference**

The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the VDP APIs. The genuine protobuf documentation can be found in our [Buf Scheme Registry (BSR)](https://buf.build/instill-ai/protobufs).

For the OpenAPI documentation, access http://localhost:3001 after `make all`, or simply run `make doc`.

## Model Hub

We curate a list of ready-to-use models for VDP. These models are from different sources and have been tested by our team. Want to contribute a new model? Please create an issue, we are happy to test and add it to the list 👐.

| Model                                                                                                                                               | Task                 | Sources                                                                                                                      | Framework | CPU | GPU | Notes |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------- | --------- | --- | --- | ----- |
| [MobileNet v2](https://github.com/onnx/models/tree/main/vision/classification/mobilenet)                                                            | Image classification | [GitHub](https://github.com/instill-ai/model-mobilenetv2), [GitHub-DVC](https://github.com/instill-ai/model-mobilenetv2-dvc) | ONNX      | ✅   | ✅   |       |
| [YOLOv4](https://github.com/AlexeyAB/darknet)                                                                                                       | Object detection     | [GitHub-DVC](https://github.com/instill-ai/model-yolov4-dvc)                                                                 | ONNX      | ✅   | ✅   |       |
| [YOLOv7](https://github.com/WongKinYiu/yolov7)                                                                                                      | Object detection     | [GitHub-DVC](https://github.com/instill-ai/model-yolov7-dvc)                                                                 | ONNX      | ✅   | ✅   |       |
| [Detectron2 Keypoint R-CNN R50-FPN](https://github.com/facebookresearch/detectron2/blob/main/configs/COCO-Keypoints/keypoint_rcnn_R_50_FPN_1x.yaml) | Keypoint detection   | [GitHub-DVC](https://github.com/instill-ai/model-keypoint-detection-dvc)                                                     | PyTorch   | ✅   | ✅   |       |
| [PSNet](https://github.com/open-mmlab/mmocr/tree/main/configs/textdet/psenet) + [EasyOCR](https://github.com/JaidedAI/EasyOCR)                      | OCR                  | [GitHub-DVC](https://github.com/instill-ai/model-ocr-dvc)                                                                    | ONNX      | ✅   | ✅   |       |
| [Mask RCNN](https://github.com/onnx/models/blob/main/vision/object_detection_segmentation/mask-rcnn/model/MaskRCNN-10.onnx)                                                                                                       | Instance segmentation     | [GitHub-DVC](https://github.com/instill-ai/model-instance-segmentation-dvc)                                                                 | PyTorch      | ✅   | ✅   |       |


Note: The `GitHub-DVC` source in the table means importing a model into VDP from a GitHub repository that uses [DVC](https://dvc.org) to manage large files.

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) - bug reports, feature requests, project discussions and contributions

- [Discord](https://discord.gg/sevxWsqpGh) - live discussion with the community and our team

- [Newsletter](https://www.instill.tech/newsletter/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) & [Twitter](https://twitter.com/instill_tech) - get the latest updates

If you are interested in hosting service of VDP, we've started signing up users to our private alpha. [Get early access](https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) and we'll contact you when we're ready.

## Contributing

We love contribution to VDP in any forms:

- Please refer to the [guideline](https://www.instill.tech/docs/development/setup-local-development/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) for local development.

- Please open a topic in the repository [Discussions](https://github.com/instill-ai/vdp/discussions) for any feature requests.

- Please open issues for bug report in the repository

  - [vdp](https://github.com/instill-ai/vdp) for general issues;

  - [pipeline-backend](https://github.com/instill-ai/pipeline-backend), [connector-backend](https://github.com/instill-ai/connector-backend), [model-backend](https://github.com/instill-ai/model-backend), [console](https://github.com/instill-ai/console), etc., for specific issues.

- Please refer to the [VDP project board](https://github.com/orgs/instill-ai/projects/5) to track progress.

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

## License

See the [LICENSE](./LICENSE) file for licensing information.

## We're hiring 🚀

Interested in building VDP with us? Join our remote team and build the future for unstructured data ETL. Check out [our open roles](https://www.instill.tech/career?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme).
