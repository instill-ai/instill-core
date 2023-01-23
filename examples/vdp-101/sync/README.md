# VDP 101 Example for `SYNC` Pipelines

This example supports [VDP 101 [4/7] How to Trigger a SYNC Pipeline](https://www.instill.tech/tutorials/vdp-101-4-how-to-trigger-a-sync-pipeline) and [VDP 101 [5/7] How to Parse Responses from SYNC Pipelines](https://www.instill.tech/tutorials/vdp-101-5-how-to-parse-vdp-responses). It showcases using [VDP](https://github.com/instill-ai/vdp) to quickly set up an **object detection (in computer vision)** pipeline with **YOLOv7**.

## 1. Prerequisites

1. Install and run VDP on your local machine (skip this if VDP is currently running on your device). Follow this tutorial [VDP 101 [2/7] Install VDP on Your Local Machine](/tutorials/vdp-101-2-installation) for more details.

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
make all
```

2. Create a `SYNC` pipeline named `vdp-101-sync` on VDP by following the instruction in [VDP 101 [3/7] Create Your First Pipeline on VDP](https://www.instill.tech/tutorials/vdp-101-3-create-your-first-pipeline).

3. (optional) Create and activate a new Conda environment with the name you prefer (e.g., `vdp-101-sync`)

```bash
# Create a new Conda environment
conda create --name vdp-101-sync
# Activate the environment created
conda activate vdp-101-sync
```

4. Run the following command to install the **dependencies** required for this example.
```bash
# Install dependencies
pip install -r requirements.txt
```
## How to run this demo

This example provides examples triggering a SYNC pipeline via three different **HTTP POST Requests**.
- `url` triggers the pipeline to download an image indicated by an URL;
- `base64` triggers the pipeline by uploading an image encoded in BASE64 string format; 
- `multipart` triggers the pipelines with multipart HTTP Request protocols, which allows uploading large objects in parallel for better multi-threaded performance and improving resilience. 

These examples can be executed as standard Python codes.

```python
# Run URL example
python sync-http-url.py
# Run base64 example
python sync-http-base64.py
# Run Multipart example
python sync-http-multipart.py
```

## Optional command-line arguments

All three example files provide optional command-line arguments for users to change the pipeline and the image they want to trigger and upload.

### URL example `sync-http-url.py`

- `--backend`: Pipeline backend URL.
- `--pipeline`: A pipeline ID indicates the pipeline to trigger.
- `--url`: File URL for object detection.

### Base64 example `sync-http-base64.py`

- `--backend`: Pipeline backend URL.
- `--pipeline`: A pipeline ID indicates the pipeline to trigger.
- `--image`: File for object detection. Note the image must be in the `/examples/sync` folder if users which to use this command-line argument.

### Multipart example `sync-http-multipart.py`

- `--backend`: Pipeline backend URL.
- `--pipeline`: A pipeline ID indicates the pipeline to trigger.
- `--image`: File name for object detection.
- `--folder`: Folder that stores the input image.


For further details about this example, please read [VDP 101 [4/7] How to Trigger a SYNC Pipeline](https://www.instill.tech/tutorials/vdp-101-4-how-to-trigger-a-sync-pipeline) and [VDP 101 [5/7] How to Parse Responses from SYNC Pipelines](https://www.instill.tech/tutorials/vdp-101-5-how-to-parse-vdp-responses).