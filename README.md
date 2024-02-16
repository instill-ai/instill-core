# Instill VDP

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/vdp?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/vdp/releases)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/vdp)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Discord&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/vdp/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/vdp/actions/workflows/integration-test-latest.yml?branch=main&event=push)

<div align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/console.svg" width=100%>
  <br>
    <em>Build, test and share your pipelines - No code required!</em>
</div>

<br>

💧 **Instill VDP (Versatile Data Pipeline)** is a source-available tool, designed to streamline your data processing pipelines from inception to completion. If your goal is to develop versatile AI features using Large Language Models (LLMs), Stable Diffusion, Vision, or Audio models, Instill VDP empowers you to:

- Effortlessly **connect** to your unstructured data
- **Build** pipelines to enable diverse AI functionalities in your applications
- Visually **test** pipelines with a single click, viewing output at each stage
- Easily **share** your pipelines to showcase your work

**☁️ [Instill Cloud](https://console.instill.tech)** offers a fully managed public cloud service, providing you with access to all the fantastic features of unstructured data ETL without the burden of infrastructure management.

## Highlights

- 🚀 Accelerate AI applications by building end-to-end AI-powered pipelines for unstructured data up to 10 times faster
- 🔌 Utilize pre-built connectors to access data from various sources, powerful AI models, and third-party tools
- 🌟 Benefit from a no-code drag-and-drop pipeline builder, enabling quick and customizable application development
- 🪢 Choose between real-time inference (SYNC) and on-demand workload (ASYNC) processing modes
- 🧁 Enjoy a scalable API-first microservice design, offering an excellent developer experience
- ⚡️ Leverage high-performing backends implemented in Go
- 📊 Gain visibility into pipeline performance through a detailed dashboard
- 🤠 Access no-code/low-code interfaces, making VDP suitable for every AI and data practitioner

## Prerequisites

- **macOS or Linux** - VDP works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - VDP uses Docker Compose (specifically, `Compose V2` and `Compose specification`) to run all services locally. Please install the latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using VDP.

## Quick Start

**Use stable release version**

Execute the following commands to pull pre-built images with all the dependencies to launch:

<!-- x-release-please-start-version -->
```bash
$ git clone -b v0.23.0-beta https://github.com/instill-ai/vdp.git && cd vdp

# Launch all services
$ make all
```
<!-- x-release-please-end -->

**Use latest version for local development**

Execute the following commands to build images with all the dependencies to launch:

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp

# Launch all services
$ make latest PROFILE=all
```

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000. Please find the default login credentials in the [documentation](https://www.instill.tech/docs/latest/quickstart#self-hosted-instill-core).

To shut down all running services:
```
$ make down
```

Explore the [documentation](https://www.instill.tech/docs/latest/core/deployment) to discover all available deployment options.

## The Unstructured Data ETL Stack

Explore the open-source unstructured data ETL stack, comprising a collection of source-available projects designed to streamline every aspect of building versatile AI features with unstructured data.

<div align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-projects.svg" width=80%>
  <br>
    <em>Open Source Unstructured Data ETL Stack</em>
</div>
<br>
<details>
  <summary><b>🔮 <a href="https://github.com/instill-ai/core" target="_blank">Instill Core</a>: The foundation for unstructured data ETL stack</b></summary><br>

  **Instill Core**, or **Core**, serves as the bedrock upon which open-source unstructured data stack thrive. Essential services such as user management servers, databases, and third-party observability tools find their home here. Instill Core also provides deployment codes to facilitate the seamless launch of both Instill VDP and Instill Model.
</details>

<details>
  <summary><b>💧 <a href="https://github.com/instill-ai/vdp" target="_blank">Instill VDP</a>: AI pipeline builder for unstructured data</b></summary><br>

  **Instill VDP**, or **VDP (Versatile Data Pipeline)**, represents a comprehensive unstructured data ETL. Its purpose is to simplify the journey of processing unstructured data from start to finish:

  - **Extract:** Gather unstructured data from diverse sources, including AI applications, cloud/on-prem storage, and IoT devices.
  - **Transform:** Utilize AI models to convert raw data into meaningful insights and actionable formats.
  - **Load:** Efficiently move processed data to warehouses, applications, or other destinations.

  Embracing VDP is straightforward, whether you opt for Instill Cloud deployment or self-hosting via Instill Core.
</details>

<details>
  <summary><b>⚗️ <a href="https://github.com/instill-ai/model" target="_blank">Instill Model</a>: Scalable AI model serving and training</b></summary><br>

  **Instill Model**, or simply **Model**, emerges as an advanced ModelOps platform. Here, the focus is on empowering you to seamlessly import, train, and serve Machine Learning (ML) models for inference purposes. Like other projects, Instill Model's source code is available for your exploration.
</details>

### No-Code/Low-Code Access

To access Instill Core and Instill Cloud, we provide:

- ⛅️ [Console](https://github.com/instill-ai/console) for non-developers, empowering them to dive into AI applications and process unstructured data without any coding.
- 🧰 CLI and SDKs for developers to seamlessly integrate with their existing data stack in minutes.
  - [Instill CLI](https://github.com/instill-ai/cli)
  - [Python SDK](https://github.com/instill-ai/python-sdk)
  - [TypeScript SDK](https://github.com/instill-ai/typescript-sdk)

## Documentation

 Please check out the [documentation](https://www.instill.tech/docs?utm_source=github&utm_medium=link&utm_campaign=core) website.

## Contributing

Please refer to the [Contributing Guidelines](./.github/CONTRIBUTING.md) for more details.

## Be Part of Us

We strongly believe in the power of community collaboration and deeply value your contributions. Head over to our [Community](https://github.com/instill-ai/community) repository, the central hub for discussing our open-source projects, raising issues, and sharing your brilliant ideas.

## License

See the [LICENSE](./LICENSE) file for licensing information.
