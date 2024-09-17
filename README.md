# 🔮 Instill Core

✨ A full-stack AI infrastructured tool for data, model and pipeline orchestration ✨

[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/instill-core/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/instill-core/actions/workflows/integration-test-latest.yml?branch=main&event=push)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/instill-core?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/instill-core/releases)
[![Artifact Hub](https://img.shields.io/endpoint?labelColor=gray&color=blue&url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/core)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Discord&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh) <!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-31-blue.svg?label=All%20Contributors)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END --> 


<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-core-stack-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-core-stack-light.svg">
    <img alt="🔮 Instill Core - The full-stack AI infrastructure tool" src="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-core-stack-light.svg" width=70%>
  </picture>
</div>

- [**💾 Instill Artifact**](https://www.instill.tech/docs/artifact/introduction/?utm_source=github&utm_medium=readme&utm_campaign=org_readme): Data orchestration to transform unstructured data into AI-ready format
- [**💧 Instill VDP**](https://www.instill.tech/docs/vdp/introduction/?utm_source=github&utm_medium=readme&utm_campaign=org_readme): Pipeline orchestration to address unstructured data ETL challenges
- [**⚗️ Instill Model**](https://www.instill.tech/docs/model/introduction/?utm_source=github&utm_medium=readme&utm_campaign=org_readme): Model orchestration for MLOps/LLMOps.


See the [Documentation](https://www.instill.tech/docs/latest/core/deployment/?utm_source=github&utm_medium=readme&utm_campaign=org_readme).


## Quick Start

### ☁️ Instill Cloud (public cloud)

**[Instill Cloud](https://instill.tech/?utm_source=github&utm_medium=readme&utm_campaign=instill-core)** is a fully managed public cloud service, providing you with access to all the features of **Instill Core** without the burden of infrastructure management. All you need to do is to one-click sign up to start building your AI-first applications.

See the [Quickstart Guide](https://www.instill.tech/docs/quickstart#%EF%B8%8F-instill-cloud?utm_source=github&utm_medium=readme&utm_campaign=instill-core).

### 🔮 Instill Core (self-hosting)

**Prerequisites**

| Operating System | Requirements and Instructions |
|------------------|--------------------------------|
| macOS or Linux   | Instill Core works natively |
| Windows          | • Use Windows Subsystem for Linux (WSL2)<br>• Install latest `yq` from [GitHub Repository](https://github.com/mikefarah/yq)<br>• Install latest Docker Desktop and enable WSL2 integration ([tutorial](https://docs.docker.com/desktop/wsl))<br>• (Optional) Install `cuda-toolkit` on WSL2 ([NVIDIA tutorial](https://docs.nvidia.com/cuda/wsl-user-guide/index.html#getting-started-with-cuda-on-wsl-2)) |
| All Systems      | • Docker Engine v25 or later<br>• Docker Compose v2 or later<br>• Install latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) |

#### Installation Options

##### 1. Use Stable Release Version

  Execute these commands to pull pre-built images with all dependencies:

  <!-- x-release-please-start-version -->
  ```bash
  git clone -b v0.40.1-beta https://github.com/instill-ai/instill-core.git
  cd instill-core

  # Launch all services
  make all
  ```
  <!-- x-release-please-end -->

  > [!NOTE]
  > For Instill Core versions up to `v0.13.0-beta`, refer to the [instill-ai/deprecated-core](https://github.com/instill-ai/deprecated-core) repository.

##### 2. Use Latest Version (for Local Development)

  Execute these commands to build images with all dependencies:

  ```bash
  git clone https://github.com/instill-ai/instill-core.git
  cd instill-core

  # Launch all services
  make latest PROFILE=all
  ```

  > [!IMPORTANT]
  > The main branch may contain unstable, under-development code. For a stable alpha version, use the [latest release](https://github.com/instill-ai/instill-core/releases).

#### Getting Started

  Once all services are up with health status:
    - Access the UI at http://localhost:3000
    - Find default login credentials in the [documentation](https://www.instill.tech/docs/latest/quickstart#self-hosted-instill-core)

  To shut down all running services:
  ```bash
  make down
  ```

  For more deployment options, see our [documentation](https://www.instill.tech/docs/latest/core/deployment).


## Client Access

To access **🔮 Instill Core** and **☁️ Instill Cloud**, you have a few options:
- <b>📺 <a href="https://github.com/instill-ai/console" target="_blank">Instill Console</a></b>
- <b>⌨️ <a href="https://github.com/instill-ai/cli" target="_blank">Instill CLI</a></b>
- <b>📦 Instill SDK</b>:
  - [Python SDK](https://github.com/instill-ai/python-sdk)
  - [TypeScript SDK](https://github.com/instill-ai/typescript-sdk)
  - Stay tuned, as more SDKs are on the way!


## 📖 Documentation & Guides

For comprehensive documentation, please visit our [official documentation](https://www.instill.tech/docs?utm_source=github&utm_medium=link&utm_campaign=instill-core).

Additional helpful resources:

- [API Reference](https://openapi.instill.tech)
- [Cookbooks](https://github.com/instill-ai/cookbook)
- [Tutorials](https://www.instill.tech/blog)
- [Examples](https://www.instill.tech/docs/examples)

## 💪 Contributing

We enthusiastically welcome contributions from our community! Whether you're a developer, designer, writer, or user, there are multiple ways to get involved:

1. **Cookbooks**: Help us create helpful pipelines and guides for the community. Visit our [Cookbook repository](https://github.com/instill-ai/cookbook) to get started.

2. **Issues**: Contribute to improvements by raising tickets using [templates here](https://github.com/instill-ai/instill-core/issues/new/choose) or discuss in existing ones you think you can helpwith. 

### Community Standards

We are committed to maintaining a respectful and welcoming atmosphere for all contributors. Before contributing, please review our:

- [Contributing Guidelines](./.github/CONTRIBUTING.md)
- [Code of Conduct](https://github.com/instill-ai/.github/blob/main/.github/CODE_OF_CONDUCT.md)

### Get Help

Get help to your queries by joining our [Discord community](https://discord.gg/sevxWsqpGh) where you can post any questions on our `#ask-for-help` channel or join Weekly Office Hours every Tuesday at 3pm BST or Thursdays at 6pm BST.


## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/VibhorGits"><img src="https://avatars.githubusercontent.com/u/110928899?v=4" width="100px;" alt=""/><br /><sub><b>Vibhor Bhatt</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/miguel-ortiz-marin"><img src="https://avatars.githubusercontent.com/u/89418691?v=4" width="100px;" alt=""/><br /><sub><b>Miguel Ortiz</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/sajdakabir"><img src="https://avatars.githubusercontent.com/u/86569763?v=4" width="100px;" alt=""/><br /><sub><b>Sajda Kabir</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/chenhunghan"><img src="https://avatars.githubusercontent.com/u/1474479?v=4" width="100px;" alt=""/><br /><sub><b>Henry Chen</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/HariBhandari07"><img src="https://avatars.githubusercontent.com/u/34328907?v=4" width="100px;" alt=""/><br /><sub><b>Hari Bhandari</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/geeksambhu"><img src="https://avatars.githubusercontent.com/u/9899283?v=4" width="100px;" alt=""/><br /><sub><b>Shiva Gaire</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/syedzubeen"><img src="https://avatars.githubusercontent.com/u/14253061?v=4" width="100px;" alt=""/><br /><sub><b>Zubeen</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/ShihChun-H"><img src="https://avatars.githubusercontent.com/u/143982976?v=4" width="100px;" alt=""/><br /><sub><b>ShihChun-H</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/eltociear"><img src="https://avatars.githubusercontent.com/u/22633385?v=4" width="100px;" alt=""/><br /><sub><b>Ikko Eltociear Ashimine</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/FarukhS52"><img src="https://avatars.githubusercontent.com/u/129654632?v=4" width="100px;" alt=""/><br /><sub><b>Farookh Zaheer Siddiqui</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/diamondsea"><img src="https://avatars.githubusercontent.com/u/847589?v=4" width="100px;" alt=""/><br /><sub><b>Brian Gallagher</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/hairyputtar"><img src="https://avatars.githubusercontent.com/u/148847552?v=4" width="100px;" alt=""/><br /><sub><b>hairyputtar</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/dmarx"><img src="https://avatars.githubusercontent.com/u/1466881?v=4" width="100px;" alt=""/><br /><sub><b>David Marx</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/DenizParlak"><img src="https://avatars.githubusercontent.com/u/11199794?v=4" width="100px;" alt=""/><br /><sub><b>Deniz Parlak</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/bryan107"><img src="https://avatars.githubusercontent.com/u/8025085?v=4" width="100px;" alt=""/><br /><sub><b>Po-Yu Chen</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/EiffelFly"><img src="https://avatars.githubusercontent.com/u/57251712?v=4" width="100px;" alt=""/><br /><sub><b>Po Chun Chiu</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/Sarthak-instill"><img src="https://avatars.githubusercontent.com/u/134260133?v=4" width="100px;" alt=""/><br /><sub><b>Sarthak</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/heiruwu"><img src="https://avatars.githubusercontent.com/u/5631010?v=4" width="100px;" alt=""/><br /><sub><b>HR Wu</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/Phelan164"><img src="https://avatars.githubusercontent.com/u/2509508?v=4" width="100px;" alt=""/><br /><sub><b>phelan</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/donch1989"><img src="https://avatars.githubusercontent.com/u/441005?v=4" width="100px;" alt=""/><br /><sub><b>Chang, Hui-Tang</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/xiaofei-du"><img src="https://avatars.githubusercontent.com/u/66248476?v=4" width="100px;" alt=""/><br /><sub><b>Xiaofei Du</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/pinglin"><img src="https://avatars.githubusercontent.com/u/628430?v=4" width="100px;" alt=""/><br /><sub><b>Ping-Lin Chang</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/tonywang10101"><img src="https://avatars.githubusercontent.com/u/78333580?v=4" width="100px;" alt=""/><br /><sub><b>Tony Wang</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/Pratikdate"><img src="https://avatars.githubusercontent.com/u/91735895?v=4" width="100px;" alt=""/><br /><sub><b>Pratik date</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/jvallesm"><img src="https://avatars.githubusercontent.com/u/3977183?v=4" width="100px;" alt=""/><br /><sub><b>Juan Vallés</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/iamnamananand996"><img src="https://avatars.githubusercontent.com/u/31537362?v=4" width="100px;" alt=""/><br /><sub><b>Naman Anand</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/totuslink"><img src="https://avatars.githubusercontent.com/u/78023102?v=4" width="100px;" alt=""/><br /><sub><b>totuslink</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/praharshjain"><img src="https://avatars.githubusercontent.com/u/12197448?v=4" width="100px;" alt=""/><br /><sub><b>Praharsh Jain</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/Smartmind12"><img src="https://avatars.githubusercontent.com/u/91927689?v=4" width="100px;" alt=""/><br /><sub><b>Utsav Paul</b></sub></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/CaCaBlocker"><img src="https://avatars.githubusercontent.com/u/87882515?v=4" width="100px;" alt=""/><br /><sub><b>CaCaBlocker</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/rsmelo92"><img src="https://avatars.githubusercontent.com/u/16295402?v=4" width="100px;" alt=""/><br /><sub><b>Rafael Melo</b></sub></a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## License

See the [LICENSE](./LICENSE) file for licensing information.
