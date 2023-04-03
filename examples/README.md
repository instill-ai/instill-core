# Example for VDP

This folder consists of diverse examples demonstrating Versatile Data Pipeline (VDP). 

## Get Started

Below are the resources available on the Instill AI websites:
- **Tutorials** provides a list of innovative use cases demonstrating the diversity and versatility of VDP.  
  - **VDP 101** is an introductory series for users to get started with VDP. We walk users through each feature provided by VDP step-by-step from installation to deploying AI models to build pipelines.
- **Documentation** provides a complete guide to VDP.
- **Blog** consists of news related and announcements of new features and releases. 

## Find desired examples with folder names

To better represent what is in each example folder, we follow a strict naming rule below:

`{app}(optional)-{AI task}-{pipeline_mode}-{source}-{destination}-{use-case}(optional)`

Example:
`metabase-cv-object-deteciton-async-http-postgres`

- `{app}(optional)` indicates the app used in this example. For instance, `metabase` is an online interactive front-end that provides real-time data extraction from databases and visualisation.
- `{AI task}` indicates the AI task demonstrated in the example. `cv-object-deteciton` means the AI task is an object detection in computer vision (CV).  
- `{pipeline_mode}` indicates the pipeline modes, including `SYNC`, `ASYNC`, and `PULL`.
- `{source}` denotes the source connector of the pipeline. At the moment, VDP supports HTTP and gRPC.
- `{destination}` indicates the destination of the pipeline. It could be either an API (e.g., HTTP and gRPC), databases (e.g., Postgres, MySQL), or spreadsheets (e.g., Google spreadsheet).
- `{use-case}(optional)` indicates the use case for this example.

## Example for Tutorials
- `instill` consists of examples where ML models are trained by Instill AI.
- `vdp-101` consists of examples used in the VDP-101 series. You can find basic but versatile examples to start building your pipelines.