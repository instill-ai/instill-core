# VDP 101 Example for `SYNC` Pipelines

This example supports [VDP 101 [4/7] How to trigger a SYNC pipeline](https://www.instill.tech/tutorials/vdp-101-4-how-to-trigger-a-sync-pipeline) and [VDP 101 [5/7] How to parse responses from SYNC pipelines](https://www.instill.tech/tutorials/vdp-101-5-how-to-parse-vdp-responses). It showcases using [VDP](https://github.com/instill-ai/vdp) to quickly set up a `SYNC` **object detection (in computer vision)** pipeline with [**YOLOv7**](https://github.com/WongKinYiu/yolov7).

## Prerequisites

1. Install and run VDP on your local machine (skip this if VDP is currently running on your device). Follow this tutorial [VDP 101 [2/7] Install VDP on Your local machine](https://www.instill.tech/tutorials/vdp-101-2-installation) for more details.

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
$ make all
```

2. Create a `SYNC` pipeline named `vdp-101-sync` on VDP by following the instruction in [VDP 101 [3/7] Create your first pipeline on VDP](https://www.instill.tech/tutorials/vdp-101-3-create-your-first-pipeline).

3. (optional) Create and activate a new Conda environment with the name you prefer (e.g., `vdp-101-sync`)

```bash
# Create a new Conda environment
$ conda create --name vdp-101-sync python=3.8
# Activate the environment created
$ conda activate vdp-101-sync
```

4. Run the following command to install the **dependencies** required for this example.
```bash
# Install dependencies
$ pip install -r requirements.txt
```
## How to run the examples

This example provides examples triggering a SYNC pipeline via three different **HTTP POST Requests**.
- `sync-http-url` triggers the pipeline to download an image indicated by an URL;
- `sync-http-base64` triggers the pipeline by uploading an image encoded in `Base64` format format; 
- `sync-http-multipart` triggers the pipelines with multipart HTTP Request protocols, which allows uploading large objects in parallel for better multi-threaded performance and improving resilience. 

These examples can be executed as standard Python codes.

### URL example `sync-http-url.py`

```bash
# Run the URL example
#   --api-gateway-url=< VDP API base URL >
#   --pipeline-id=< Pipeline ID indicates the pipeline to trigger>
#   --image-url=< Image URL for object detection >
$ python sync-http-url.py --api-gateway-url=http://localhost:8080 --pipeline-id=vdp-101-sync --image-url=https://artifacts.instill.tech/imgs/dog.jpg
```

### Base64 example `sync-http-base64.py`

```bash
# Run base64 example
#   --api-gateway-url=< VDP API base URL >
#   --pipeline-id=< Pipeline ID indicates the pipeline to trigger>
#   --image-file=< Local image file path for object detection >
$ python sync-http-base64.py --api-gateway-url=http://localhost:8080 --pipeline-id=vdp-101-sync --image-file=dog.jpg
```

### Multipart example `sync-http-multipart.py`

```bash
# Run Multipart example
#   --api-gateway-url=< VDP API base URL >
#   --pipeline-id=< Pipeline ID indicates the pipeline to trigger>
#   --image-file=< Local image file path for object detection >
$ python sync-http-multipart.py --api-gateway-url=http://localhost:8080 --pipeline-id=vdp-101-sync --image-file=dog.jpg
```

For further details about this example, please read [VDP 101 [4/7] How to trigger a SYNC pipeline](https://www.instill.tech/tutorials/vdp-101-4-how-to-trigger-a-sync-pipeline) and [VDP 101 [5/7] How to parse responses from SYNC pipelines](https://www.instill.tech/tutorials/vdp-101-5-how-to-parse-vdp-responses).