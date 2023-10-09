# Instill VDP

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/vdp?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/vdp/releases)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/vdp)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Community&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/vdp/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/vdp/actions/workflows/integration-test-latest.yml?branch=main&event=push)
[![Documentation deployment workflow](https://img.shields.io/github/actions/workflow/status/instill-ai/instill.tech/release.yml?branch=main&label=Docs&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDAuNzUwMDA0QzAgMC41NTEwOTEgMC4wNzkwMTc2IDAuMzYwMzI2IDAuMjE5NjcgMC4yMTk2NzRDMC4zNjAzMjIgMC4wNzkwMjEzIDAuNTUxMDg4IDMuNjgxOTFlLTA2IDAuNzUgMy42ODE5MWUtMDZINS4wMDNDNi4yMyAzLjY4MTkxZS0wNiA3LjMyIDAuNTkwMDA0IDguMDAzIDEuNTAxQzguMzUyMTggMS4wMzQzMyA4LjgwNTQ4IDAuNjU1NjI3IDkuMzI2ODMgMC4zOTUwNDJDOS44NDgxNyAwLjEzNDQ1NiAxMC40MjMyIC0wLjAwMDgxMzY0NiAxMS4wMDYgMy42ODE5MWUtMDZIMTUuMjUxQzE1LjQ0OTkgMy42ODE5MWUtMDYgMTUuNjQwNyAwLjA3OTAyMTMgMTUuNzgxMyAwLjIxOTY3NEMxNS45MjIgMC4zNjAzMjYgMTYuMDAxIDAuNTUxMDkxIDE2LjAwMSAwLjc1MDAwNFYxMS4yNUMxNi4wMDEgMTEuNDQ4OSAxNS45MjIgMTEuNjM5NyAxNS43ODEzIDExLjc4MDNDMTUuNjQwNyAxMS45MjEgMTUuNDQ5OSAxMiAxNS4yNTEgMTJIMTAuNzQ0QzEwLjQ0ODUgMTIgMTAuMTU1OSAxMi4wNTgyIDkuODgyOTYgMTIuMTcxM0M5LjYwOTk3IDEyLjI4NDMgOS4zNjE5MyAxMi40NTAxIDkuMTUzIDEyLjY1OUw4LjUzMSAxMy4yOEM4LjM5MDM3IDEzLjQyMDUgOC4xOTk3NSAxMy40OTkzIDguMDAxIDEzLjQ5OTNDNy44MDIyNSAxMy40OTkzIDcuNjExNjMgMTMuNDIwNSA3LjQ3MSAxMy4yOEw2Ljg0OSAxMi42NTlDNi42NDAwNyAxMi40NTAxIDYuMzkyMDMgMTIuMjg0MyA2LjExOTA0IDEyLjE3MTNDNS44NDYwNiAxMi4wNTgyIDUuNTUzNDggMTIgNS4yNTggMTJIMC43NUMwLjU1MTA4OCAxMiAwLjM2MDMyMiAxMS45MjEgMC4yMTk2NyAxMS43ODAzQzAuMDc5MDE3NiAxMS42Mzk3IDAgMTEuNDQ4OSAwIDExLjI1TDAgMC43NTAwMDRaTTguNzU1IDMuNzVDOC43NTUgMy4xNTMyNyA4Ljk5MjA1IDIuNTgwOTcgOS40MTQwMSAyLjE1OTAxQzkuODM1OTcgMS43MzcwNiAxMC40MDgzIDEuNSAxMS4wMDUgMS41SDE0LjVWMTAuNUgxMC43NDNDMTAuMDMzIDEwLjUgOS4zNDMgMTAuNzAxIDguNzUxIDExLjA3Mkw4Ljc1NSAzLjc1VjMuNzVaTTcuMjUxIDExLjA3NEw3LjI1NSA2LjAwMUw3LjI1MyAzLjc0OEM3LjI1MjQ3IDMuMTUxNjEgNy4wMTUxOCAyLjU3OTgzIDYuNTkzMjggMi4xNTgzMUM2LjE3MTM4IDEuNzM2NzggNS41OTkzOSAxLjUgNS4wMDMgMS41SDEuNVYxMC41SDUuMjU3QzUuOTYyNDIgMTAuNSA2LjY1MzU1IDEwLjY5ODkgNy4yNTEgMTEuMDc0VjExLjA3NFoiIGZpbGw9IndoaXRlIi8+Cjwvc3ZnPgo=)](https://github.com/instill-ai/instill.tech/actions/workflows/deploy-prod.yml)
[![License MIT](https://img.shields.io/badge/License-MIT-blue)](https://github.com/instill-ai/vdp/blob/main/protocol/LICENSE)
[![License ELv2](https://img.shields.io/badge/License-ELv2%20-blue)](https://github.com/instill-ai/vdp/blob/main/LICENSE)

<div align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-cloud-demo-generative-art-template.gif" width=100%>
  <br>
    <em>Build, test and share your pipelines - No code required!</em>
</div>

<br>

💧 **Instill VDP (Versatile Data Pipeline)** is a source-available tool, designed to streamline your data processing pipelines from inception to completion. If your goal is to develop versatile AI features using Large Language Models (LLM), Generative AI, Vision, or Audio models, Instill VDP empowers you to:

- Effortlessly **connect** to your unstructured data
- **Build** pipelines to enable diverse AI functionalities in your applications
- Visually **test** pipelines with a single click, viewing output at each stage
- Easily **share** your pipelines to showcase your work

**☁️ [Instill Cloud](https://console.instill.tech)** is a fully-managed public cloud service that grants you access to all the fantastic features of Instill VDP, without the hassle of managing infrastructure.

## Highlights

- 🚀 Accelerate AI applications by building end-to-end AI-powered pipelines for unstructured data up to 10 times faster
- 🔌 Utilize pre-built connectors to access data from various sources, powerful AI models, and third-party tools
- 🌟 Benefit from a no-code drag-and-drop pipeline builder, enabling quick and customizable application development
- 🪢 Choose between real-time inference (SYNC) and on-demand workload (ASYNC) processing modes
- 🧁 Enjoy a scalable API-first microservice design, offering an excellent developer experience
- ⚡️ Leverage high-performing backends implemented in Go
- 📊 Gain visibility into pipeline performance through a detailed dashboard
- 🤠 Access no-/low-code interfaces, making VDP suitable for every AI and data practitioner

## Prerequisites

- **macOS or Linux** - VDP works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - VDP uses Docker Compose (specifically, `Compose V2` and `Compose specification`) to run all services at local. Please install the latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using VDP.

## Quick Start

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

Execute the following commands to start pre-built images with all the dependencies:

**The stable release version**

<!-- x-release-please-start-version -->
```bash
$ git clone -b v0.15.0-alpha https://github.com/instill-ai/vdp.git && cd vdp

# Launch all services
$ make all
```
<!-- x-release-please-end -->

**The latest version for development**

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp

# Launch all services
$ make latest PROFILE=all
```

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000!

To shut down all running services:
```
$ make down
```

Explore our [documentation](https://www.instill.tech/docs/vdp/deployment/overview) to discover all available deployment options.

## Dive into the Projects

Instill VDP stands as a crucial project within our **[Instill Core](https://github.com/instill-ai#instill-core)** stack. It provides an open-source AI infrastructure tailored for unstructured data, enabling versatile AI application development. Within this ecosystem, delve into source-available projects that enable you to construct flexible AI pipelines, enhancing your data processing abilities and converting raw data into actionable insights.

- 💧 [Instill VDP](https://github.com/instill-ai/vdp): Streamline the unstructured data journey for AI applications
- ⚗️ [Instill Model](https://github.com/instill-ai/model): Transform your applications with AI models
- 🗿 [Instill Base](https://github.com/instill-ai/base): Essential Services for VDP and Model

## No-/Low-code Access & Support

To dive into Instill Core and Instill Cloud, we provide:

- ✨ [Console](https://github.com/instill-ai/console) for non-developers, empowering them to dive into AI applications and process unstructured data without any coding.
- 🧰 CLI and SDKs for developers to seamlessly integrate with their existing data stack in minutes.
  - [Instill CLI](https://github.com/instill-ai/cli)
  - [Python SDK](https://github.com/instill-ai/python-sdk)
  - [TypeScript SDK](https://github.com/instill-ai/typescript-sdk)
- 🙌 Join our [Discord](https://discord.gg/sevxWsqpGh) server to exchange ideas about unstructured data processing, AI, MLOps, and get support from the Instill AI team. We're here to support you every step of the way!

## Documentation

- 📔 **Documentation** - Check out the **[documentation](https://www.instill.tech/docs?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme)** website.
- 📘 **API Reference** - Access http://localhost:3001 after `make all`, or simply run `make doc` to access the _OpenAPI documentation_. The gRPC protocols in [protobufs](https://github.com/instill-ai/protobufs) provide the single source of truth for the VDP APIs. The genuine protobuf documentation can be found in our [Buf Scheme Registry (BSR)](https://buf.build/instill-ai/protobufs).

## Be Part of Our Community

We strongly believe in the power of community collaboration and deeply value your contributions. Head over to our [Community](https://github.com/instill-ai/community) repository, the central hub for discussing our open-source projects, raising issues, and sharing your brilliant ideas.


## Contributing

Please refer to the [Contributing Guidelines](./.github/CONTRIBUTING.md) for more details.


## License

See the [LICENSE](./LICENSE) file for licensing information.
