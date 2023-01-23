# Example for VDP

This folder consists of diverse examples demonstrating Versatile Data Pipeline (VDP). 

## Get Started

Below are the resources available on the Instill AI websites:
- **VDP 101** is an introductory series for users to get started with VDP. We walk users through each feature (from VDP installation to deploying your own AI model on VDP) provided by VDP step-by-step. We also provide simple examples to build your first pipeline on VDP.
- **Use Cases** provides a list of examples demonstrating the diversity and versatility of VDP. You can find pipeline examples built for different AI tasks and apps that help to store, analyze, and visualize the pipeline outputs.
- **Documentation** provides a complete guide to VDP.
- **Blog** consists of news related and announcements of new features and releases. 

## Find desired examples with folder names

To better represent what is in each example folder, we follow a strict naming rule below:

`(optional){app}-{AI task}-{pipeline_mode}-{source}-{destination}`

Example:
`metabase-cv-object-deteciton-async-http-postgres`

- `{app}(optional)`: this indicates the app used in this example. For instance, `metabase` is an online interactive front-end that provides real-time data extraction from databases and visualization.
- `{AI task}`: this indicates the AI task demonstrated in the example. `cv-object-deteciton` means the AI task is an object detection in computer vision (CV).  
- `{pipeline_mode}`: this indicates the pipeline modes, including `SYNC`, `ASYNC`, and `PULL`.
- `{source}`: this denotes the source connector of the pipeline. At the moment, VDP supports HTTP and gRPC.
- `{destination}`: this indicates the destination of the pipeline. It could be either an API (e.g., HTTP and gRPC), databases (e.g., Postgres, MySQL), or spreadsheets (e.g., Google spreadsheet).

## Special folders (that do not follow the naming rule)
- `instill-customsed-models`: this folder consists of examples where ML models trained by instill.
- `vdp-101`: this folder consists of examples used in the VDP-101 series. You can find basic but versatile examples to start building your pipelines.