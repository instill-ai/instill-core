# Instill Core

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/core?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/core/releases)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/core)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Discord&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/core/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/core/actions/workflows/integration-test-latest.yml?branch=main&event=push)
[![Documentation deployment workflow](https://img.shields.io/github/actions/workflow/status/instill-ai/instill.tech/release.yml?branch=main&label=Docs&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDAuNzUwMDA0QzAgMC41NTEwOTEgMC4wNzkwMTc2IDAuMzYwMzI2IDAuMjE5NjcgMC4yMTk2NzRDMC4zNjAzMjIgMC4wNzkwMjEzIDAuNTUxMDg4IDMuNjgxOTFlLTA2IDAuNzUgMy42ODE5MWUtMDZINS4wMDNDNi4yMyAzLjY4MTkxZS0wNiA3LjMyIDAuNTkwMDA0IDguMDAzIDEuNTAxQzguMzUyMTggMS4wMzQzMyA4LjgwNTQ4IDAuNjU1NjI3IDkuMzI2ODMgMC4zOTUwNDJDOS44NDgxNyAwLjEzNDQ1NiAxMC40MjMyIC0wLjAwMDgxMzY0NiAxMS4wMDYgMy42ODE5MWUtMDZIMTUuMjUxQzE1LjQ0OTkgMy42ODE5MWUtMDYgMTUuNjQwNyAwLjA3OTAyMTMgMTUuNzgxMyAwLjIxOTY3NEMxNS45MjIgMC4zNjAzMjYgMTYuMDAxIDAuNTUxMDkxIDE2LjAwMSAwLjc1MDAwNFYxMS4yNUMxNi4wMDEgMTEuNDQ4OSAxNS45MjIgMTEuNjM5NyAxNS43ODEzIDExLjc4MDNDMTUuNjQwNyAxMS45MjEgMTUuNDQ5OSAxMiAxNS4yNTEgMTJIMTAuNzQ0QzEwLjQ0ODUgMTIgMTAuMTU1OSAxMi4wNTgyIDkuODgyOTYgMTIuMTcxM0M5LjYwOTk3IDEyLjI4NDMgOS4zNjE5MyAxMi40NTAxIDkuMTUzIDEyLjY1OUw4LjUzMSAxMy4yOEM4LjM5MDM3IDEzLjQyMDUgOC4xOTk3NSAxMy40OTkzIDguMDAxIDEzLjQ5OTNDNy44MDIyNSAxMy40OTkzIDcuNjExNjMgMTMuNDIwNSA3LjQ3MSAxMy4yOEw2Ljg0OSAxMi42NTlDNi42NDAwNyAxMi40NTAxIDYuMzkyMDMgMTIuMjg0MyA2LjExOTA0IDEyLjE3MTNDNS44NDYwNiAxMi4wNTgyIDUuNTUzNDggMTIgNS4yNTggMTJIMC43NUMwLjU1MTA4OCAxMiAwLjM2MDMyMiAxMS45MjEgMC4yMTk2NyAxMS43ODAzQzAuMDc5MDE3NiAxMS42Mzk3IDAgMTEuNDQ4OSAwIDExLjI1TDAgMC43NTAwMDRaTTguNzU1IDMuNzVDOC43NTUgMy4xNTMyNyA4Ljk5MjA1IDIuNTgwOTcgOS40MTQwMSAyLjE1OTAxQzkuODM1OTcgMS43MzcwNiAxMC40MDgzIDEuNSAxMS4wMDUgMS41SDE0LjVWMTAuNUgxMC43NDNDMTAuMDMzIDEwLjUgOS4zNDMgMTAuNzAxIDguNzUxIDExLjA3Mkw4Ljc1NSAzLjc1VjMuNzVaTTcuMjUxIDExLjA3NEw3LjI1NSA2LjAwMUw3LjI1MyAzLjc0OEM3LjI1MjQ3IDMuMTUxNjEgNy4wMTUxOCAyLjU3OTgzIDYuNTkzMjggMi4xNTgzMUM2LjE3MTM4IDEuNzM2NzggNS41OTkzOSAxLjUgNS4wMDMgMS41SDEuNVYxMC41SDUuMjU3QzUuOTYyNDIgMTAuNSA2LjY1MzU1IDEwLjY5ODkgNy4yNTEgMTEuMDc0VjExLjA3NFoiIGZpbGw9IndoaXRlIi8+Cjwvc3ZnPgo=)](https://github.com/instill-ai/instill.tech/actions/workflows/deploy-prod.yml)

<div align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-projects.svg" >
  <br>
    <em>Instill Core: Open-source Orchestrator for Data, AI and Pipelines</em>
</div>

<br>

Explore 🔮 **[Instill Core](https://github.com/instill-ai/core)**, the open-source orchestrator comprising a collection of source-available projects designed to streamline every aspect of building versatile AI features with unstructured data. Access Instill Core is straightforward, whether you opt for Instill Cloud deployment or self-hosting via Instill Core. Consult our comprehensive [documentation](https://www.instill.tech/docs/latest/core/deployment).

<details>
  <summary><b>💧 Instill VDP</b>: Unstructured data, AI and pipeline orchestration</summary><br>

  **Instill VDP**, also known as **VDP (Versatile Data Pipeline)**, serves as a powerful data orchestrator tailored to address unstructured data ETL challenges.

  - Simplify the journey of processing unstructured data from diverse sources, including AI applications, cloud/on-prem storage, and IoT devices. Utilize AI models and embed business logic to transform raw data into meaningful insights and actionable formats. Efficiently load processed data to warehouses, applications, or other destinations.
  - Build flexible, durable pipelines with features like failover, automatic retries, rate limiting, and batching to handle high-volume data straight out of the box.

  <div align="center">
    <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/console.svg" width=100%>
    <br>
      <em>Build, test and share your pipelines - No code required!</em>
  </div>

  <br>

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

Not quite into self-hosting? We've got you covered with ☁️ **[Instill Cloud](https://instill.tech)**. It's a fully managed public cloud service, providing you with access to all the fantastic features of unstructured data orchestration without the burden of infrastructure management.

## Prerequisites

- **macOS or Linux** - Instill Core works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - Instill Core uses Docker Compose (specifically, `Compose V2` and `Compose specification`) to run all services locally. Please install the latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using Instill Core.

## Quick Start

**Use stable release version**

Execute the following commands to pull pre-built images with all the dependencies to launch:

<!-- x-release-please-start-version -->
```bash
$ git clone -b v0.12.0-beta https://github.com/instill-ai/core.git && cd core

# Launch all services
$ make all
```
<!-- x-release-please-end -->

**Use the latest version for local development**

Execute the following commands to build images with all the dependencies to launch:

```bash
$ git clone https://github.com/instill-ai/core.git && cd core

# Launch all services
$ make latest PROFILE=all
```

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/core/releases).

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000. Please find the default login credentials in the [documentation](https://www.instill.tech/docs/latest/quickstart#self-hosted-instill-core).

To shut down all running services:
```
$ make down
```

Explore the [documentation](https://www.instill.tech/docs/latest/core/deployment) to discover all available deployment options.

## No-Code/Low-Code Access

To dive into Instill Core and Instill Cloud, you have a few options:

> **Note**
> To access Instill Cloud, [register](https://instill.tech/?utm_source=github&utm_medium=readme&utm_campaign=community) an account with your email address.

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

Please check out the [documentation](https://www.instill.tech/docs?utm_source=github&utm_medium=link&utm_campaign=core) and the [API reference](https://openapi.instill.tech?utm_source=github&utm_medium=link&utm_campaign=core).
The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the Core APIs. The genuine protobuf documentation can be found in our [Buf Scheme Registry (BSR)](https://buf.build/instill-ai/protobufs).

## Be Part of Us and Make a Difference

We strongly believe in the power of community collaboration and deeply value your contributions. Here's how you can join the conversation and make an impact:

- Stay updated with our [Changelog](https://instill-ai.productlane.com/changelog) to track the latest progress of our ongoing projects.

- Visit our [Community](https://github.com/instill-ai/community) repository, the central space for discussions on our open-source projects. You can raise [issues](https://github.com/instill-ai/community/issues) there to engage in ongoing conversations. Whether it's reporting a bug or suggesting a new feature or enhancement, don't hesitate to [open an issue](https://github.com/instill-ai/community/issues/new/choose).

- Join our [Discord](https://discord.gg/sevxWsqpGh) server to exchange ideas about unstructured data processing, AI, MLOps, LLMOps and get support from the Instill AI team. We're here to support you every step of the way!

### Contributing

We welcome contributions from the community! Whether you're a developer, designer, writer, or user, there are multiple ways to contribute:

#### Issue Guidelines

We foster a friendly and inclusive environment for issue reporting. Before [creating an issue](https://github.com/instill-ai/community/issues/new/choose), check if it already exists. Use clear language and provide reproducible steps for bugs. Accurately tag the issue (bug, improvement, question, etc.).

#### Code Contributions

Please refer to the [Contributing Guidelines](./.github/CONTRIBUTING.md) for more details.

## License

See the [LICENSE](./LICENSE) file for licensing information.
