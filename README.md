<h1 align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.svg" alt="Visual Data Preparation: open-source visual data ETL">
</h1>

<h4 align="center">
    <a href="https://www.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Website</a> |
    <a href="https://discord.gg/sevxWsqpGh">Community</a> |
    <a href="https://blog.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Blog</a>
</h4>

---

**Visual Data Preparation (VDP)** is an open-source visual data ETL tool to streamline the end-to-end visual data processing pipeline:

1. **Extract** unstructured visual data from pre-built data sources such as cloud/on-prem storage, or IoT devices
2. **Transform** it into analysable structured data by Vision AI models
3. **Load** the transformed data into warehouses, applications, or other destinations

## Why we build VDP

Before we started to build VDP, for years, we'd fought with streaming large volume data (billions of images a day!) to automate vision tasks using deep learning-based computer vision.

We've learned that model serving for a robust end-to-end data flow requires not only **high throughput** and **low latency** but also **cost efficiency**, which altogether is non-trivial. Building from scratch, we had a battle-proven system built in-house running in production for years.

We'd love to generalise the infrastructure and make Vision AI more accessible to everyone. Fortunately what we had built can actually be modularised into working components to be used for a broader spectrum of vision tasks and industry sectors.

The goal of VDP is to seamlessly bring Vision AI into the modern data stack with a standardised framework. Check our blog post [Missing piece in modern data stack: visual data preparation](https://blog.instill.tech/visual-data-preparation/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) on how this tool is proposed to streamline unstructured visual data processing across different stakeholders.

## Highlights

- 🚀 **The fastest way to build end-to-end visual data pipelines** - building a pipeline is like assembling LEGO blocks

- 🖱️ **One-click import & deploy ML/DL models** from popular GitHub, [Hugging Face](https://huggingface.co) or cloud storage managed by version control tools like [DVC](https://dvc.org) or [ArtiVC](https://artivc.io)

- 📦 **Standardised vision task** structured output formats to streamline with data warehouse

- 🔌 **Pre-built ETL data connectors** for extensive data access

- 🪢 **Build pipelines for diverse scenarios** - **SYNC** for real-time inference and **ASYNC** for on-demand workload

- 🧁 **Scalable API-first microservice design for great developer experience** - seamless integration to modern data stack at any scale

- 🤠 **Build for every Vision AI practitioner** - The no-/low-code interface helps take off your AI Researcher/AI Engineer/Data Engineer/Data Scientist hat and *put on the all-rounder hat* to deliver more with VDP

## How VDP works

The core concept of VDP is _pipeline_. A pipeline is an end-to-end workflow that automates a sequence of tasks to process visual data. Each pipeline is defined and formed by a _recipe_ that contains three components:
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
> We use **connector** as a general term to represent data source and destination. Please find the supported connectors [here](docs/connector.md).

### Guidance philosophy
We expect VDP to be exposed to more MLOps integrations in the future, it is implemented with microservice and API-first design principle. Instead of building all components from scratch, we've decided to adopt sophisticated open-source tools:

- [Triton Inference Server](https://github.com/triton-inference-server/server) for high-performance model serving

- [Temporal](https://github.com/temporalio/temporal) for a reliable, durable and scalable workflow engine

- [Airbyte](https://github.com/airbytehq/airbyte) for abundant destination connectors

, and hope VDP can also enrich the open-source communities in a way to bring more practical use cases in unstructured visual data processing.

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

## Documentation

📔 **Documentation & tutorials are coming soon!**

📘 **API Reference**

The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the VDP APIs. The genuine protobuf documentation can be found in our [Buf Scheme Registry (BSR)](https://buf.build/instill-ai/protobufs).

For the OpenAPI documentation, access http://localhost:3001 after `make all`, or simply run `make doc`.

## Contribution

We love contribution to VDP in any forms:

- Please refer to the [guide](docs/development.md) for local development.
- Please open general issues in
  - [instill-ai/vdp](https://github.com/instill-ai/vdp) for general issues;
  - [pipeline-backend](https://github.com/instill-ai/pipeline-backend), [connector-backend](https://github.com/instill-ai/connector-backend), [model-backend](https://github.com/instill-ai/model-backend), [mgmt-backend](https://github.com/instill-ai/mgmt-backend), etc., for any backend specific issues.
- Please refer to the [VDP project board](https://github.com/orgs/instill-ai/projects/5) to track progress

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) (bug reports, feature requests, project discussions and contributions)
- [Discord](https://discord.gg/sevxWsqpGh) (live discussion with the community and our team)

If you are interested in hosting service of VDP, we've started signing up users to our private alpha. [Get early access](https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) and we'll contact you when we're ready.

## License

See the [LICENSE](./LICENSE) file for licensing information.
