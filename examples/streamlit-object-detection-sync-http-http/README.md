# YOLOv4 vs. YOLOv7 demo

This demo is to showcase using [VDP](https://github.com/instill-ai/vdp) to quickly set up a [YOLOv7](https://github.com/WongKinYiu/yolov7) Object Detection pipeline. It also uses [Streamlit](https://streamlit.io) to qualitatively compare the detection results with a [YOLOv4](https://github.com/AlexeyAB/darknet) pipeline.

## Preparation
Run VDP locally

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
$ make all
```

 Create two pipelines: `yolov4` and `yolov7` by following the [tutorial](https://www.instill.tech/tutorials/vdp-streamlit-yolov7).

## How to run the demo
Run the following command
```bash
# Install dependencies
$ pip install -r requirements.txt

# Run the demo
#   --demo-url=< demo URL >
#   --api-gateway-url=< VDP API base URL >
#   --yolov4=< YOLOv4 pipeline ID >
#   --yolov7=< YOLOv7 pipeline ID >
$ streamlit run main.py -- --demo-url=http://localhost:8501 --api-gateway-url=http://localhost:8080 --yolov4=yolov4 --yolov7=yolov7
```
Now go to `http://localhost:8501/` 🎉

## Deploy the demo using Docker
Alternatively, you can run the demo using Docker.

Build a Docker image
```bash
$ docker build -t vdp-streamlit-object-detection .
```
Run the Docker container and connect to VDP
```bash
$ docker run --rm --name vdp-streamlit-object-detection -p 8501:8501 --network instill-network vdp-streamlit-object-detection -- --demo-url=http://localhost:8501 --api-gateway-url=http://api-gateway:8080 --yolov4=yolov4 --yolov7=yolov7

You can now view your Streamlit app in your browser.

  URL: http://0.0.0.0:8501

```

## Shut down VDP

To shut down all running VDP services:
```
$ make down
```
