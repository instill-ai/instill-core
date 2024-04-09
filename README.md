# Instill Core

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/instill-core?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/instill-core/releases)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/instill-core)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Discord&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/instill-core/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/instill-core/actions/workflows/integration-test-latest.yml?branch=main&event=push)

<div align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-projects.svg" >
  <br>
    <em>Open-source orchestrator for data, AI and pipelines</em>
</div>

<br>

Explore **🔮 Instill Core**, the open-source orchestrator comprising a collection of source-available projects designed to streamline every aspect of building versatile AI features with unstructured data.

<details>
  <summary><b>💧 Instill VDP</b>: Unstructured data, AI and pipeline orchestration</summary><br>

  <div align="center">
    <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/console.svg" width=100%>
    <br>
    <em>Build, test and share your pipelines - No code required!</em>
  </div>

  <br>

  **Instill VDP**, also known as **VDP (Versatile Data Pipeline)**, serves as a powerful data orchestrator tailored to address unstructured data ETL challenges.

  - Simplify the journey of processing unstructured data from diverse sources, including AI applications, cloud/on-prem storage, and IoT devices. Utilize AI models and embed business logic to transform raw data into meaningful insights and actionable formats. Efficiently load processed data to warehouses, applications, or other destinations.
  - Build flexible, durable pipelines with features like failover, automatic retries, rate limiting, and batching to handle high-volume data straight out of the box.
</details>

<details>
  <summary><b>⚗️ Instill Model</b>: Scalable MLOps and LLMOps for open-source or custom AI models</summary><br>

  **Instill Model**, or simply **Model**, an advanced ModelOps/LLMOps platform focused on empowering users to seamlessly import, serve, fine-tune, and monitor Machine Learning (ML) models for continuous optimization.
</details>

<details>
  <summary><b>💾 Instill Artifact</b>: Unified unstructured data management platform</summary><br>

  **Instill Artifact**, or simply **Artifact**, is your platform for transforming documents (e.g., HTML, PDF, CSV, PPTX, DOC), images (e.g., JPG, PNG, TIFF), audio (e.g., WAV, MP3 ) and video (e.g., MP4, MOV) of various formats into a unified AI-ready format. It ensures your data is clean, curated, and ready for extracting insights and building your knowledge base.
</details>

### Instill Cloud

Not quite into self-hosting? We've got you covered with **☁️ [Instill Cloud](https://instill.tech/?utm_source=github&utm_medium=readme&utm_campaign=instill-core)**. It's a fully managed public cloud service, providing you with access to all the fantastic features of unstructured data orchestration without the burden of infrastructure management.

## Prerequisites

- **macOS or Linux** - Instill Core works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - Instill Core uses Docker Compose (specifically, `Compose V2` and `Compose specification`) to run all services locally. Please install the latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using Instill Core.

## Quick Start

**Use stable release version**

Execute the following commands to pull pre-built images with all the dependencies to launch:

<!-- x-release-please-start-version -->
```bash
$ git clone -b v0.28.0-beta https://github.com/instill-ai/instill-core.git && cd instill-core

# Launch all services
$ make all
```
<!-- x-release-please-end -->

> [!NOTE]
> We have restructured our project repositories. If you need to access Instill Core projects up to version `v0.13.0-beta`, please refer to the [instill-ai/deprecated-core](https://github.com/instill-ai/deprecated-core) repository.

**Use the latest version for local development**

Execute the following commands to build images with all the dependencies to launch:

```bash
$ git clone https://github.com/instill-ai/instill-core.git && cd instill-core

# Launch all services
$ make latest PROFILE=all
```

> [!IMPORTANT]
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/instill-core/releases).

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000. Please find the default login credentials in the [documentation](https://www.instill.tech/docs/latest/quickstart#self-hosted-instill-core).

To shut down all running services:
```
$ make down
```

Explore the [documentation](https://www.instill.tech/docs/latest/core/deployment) to discover all available deployment options.

## No-Code/Low-Code Access

To dive into Instill Core and Instill Cloud, you have a few options:

> **Note**
> To access Instill Cloud, [register](https://instill.tech/?utm_source=github&utm_medium=readme&utm_campaign=instill-core) an account with your email address.

<details>
  <summary><b>⛅ <a href="https://github.com/instill-ai/console" target="_blank">Instill Console</a>: Dive in Instill Core/Cloud with no coding</b></summary><br>

  **Instill Console**, or **Console** is a user-friendly web-based UI application that improves accessibility and usability across both Instill Core and Instill Cloud. It allows you to dive into the creation of AI apps or the processing of unstructured data without the need for coding skills.

  To access the Instill Core console, please launch Instill Core and navigate to http://localhost:3000. For the Instill Cloud console, simply go to https://instill.tech.
</details>

<details>
  <summary><b>📺 <a href="https://github.com/instill-ai/cli" target="_blank">Instill CLI</a>:  Bring Instill Core/Cloud to your command line</b></summary><br>

  **Instill CLI** enables you to access Instill Core and Instill Cloud from your terminal. It can be installed by `brew install instill-ai/tap/inst` for Linux and macOS. To set up and get started with Instill CLI, head over [here](https://github.com/instill-ai/cli).
</details>

<details>
  <summary><b>📦 Instill SDKs</a>: Integrate Instill Core/Cloud with your language of choice </b></summary><br>

  **Instill SDKs** make it easy for developers to integrate and interact with Instill Core and Cloud.

  - [Python SDK](https://github.com/instill-ai/python-sdk)
  - [TypeScript SDK](https://github.com/instill-ai/typescript-sdk)
  - Stay tuned, as more SDKs are on the way!
</details>

## Documentation

 For comprehensive guidance and resources, explore our [documentation website](https://www.instill.tech/docs?utm_source=github&utm_medium=link&utm_campaign=instill-core) and delve into our [API reference](https://openapi.instill.tech).

## Contributing

Please refer to the [Contributing Guidelines](./.github/CONTRIBUTING.md) for more details.

## Be Part of Us

We strongly believe in the power of community collaboration and deeply value your contributions. Head over to our [Community](https://github.com/instill-ai/community) repository, the central hub for discussing our open-source projects, raising issues, and sharing your brilliant ideas.

## License

See the [LICENSE](./LICENSE) file for licensing information.
