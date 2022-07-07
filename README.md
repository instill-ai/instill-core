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

1. **Ingest** unstructured visual data from pre-built data sources such as cloud and on-prem storage, or IoT devices
2. **Transform** it into analysable structured data by Vision AI models
3. **Load** the transformed data into warehouses, applications, or other destinations

## Why we build VDP

The goal of VDP is to seamlessly bring Vision AI into the modern data stack with a standardised framework. Check our blog post [Missing piece in modern data stack: visual data preparation](https://blog.instill.tech/visual-data-preparation/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) on how this tool is proposed to streamline unstructured visual data processing across different stakeholders.

## How VDP works

The core concept of VDP is _pipeline_. A pipeline is an end-to-end workflow that automates a sequence of tasks to process visual data. Each pipeline consists of three ordered components:
1. **data source**: where the pipeline starts. It connects the source of image and video data to be processed.
2. **model**: a deployed Vision AI model to process the ingested visual data and generate structured outputs
3. **data destination**: where to send the structured outputs

Based on [the mode of a pipeline](docs/pipeline-mode.md), it will ingest and process the visual data, send the outputs to the destination every time the trigger event occurs.

We use **data connector** as a general term to represent data source and data destination. Please find the supported data connectors [here](docs/connector.md).

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
> The image of model-backend (~2GB) and Triton Server (~11GB) can take a while to pull, but this should be an one-time effort at the first setup.

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

📔 Documentation & tutorials are coming soon!

**API Reference**

The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the VDP APIs. The genuine protobuf documentation can be found in our [Buf Scheme Registry (BSR)](https://buf.build/instill-ai/protobufs).

For the OpenAPI documentation, access http://localhost:3001 after `make all`, or simply run `docker-compose up -d redoc_openapi`.

## Local development

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

Please refer to the [guide](docs/development.md) for local development.

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) (bug reports, feature requests, project discussions and contributions)
- [Discord](https://discord.gg/sevxWsqpGh) (live discussion with the community and our team)

If you are interested in hosting service of VDP, we've started signing up users to our private alpha. [Get early access](https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) and we'll contact you when we're ready. 

## License

See the [LICENSE](./LICENSE) file for licensing information.
