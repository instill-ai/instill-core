# 🔥 YOLOv7 demo

This demo is to showcase [YOLOv4](https://github.com/AlexeyAB/darknet) vs. [YOLOv7](https://github.com/WongKinYiu/yolov7) models pre-trained with [MS-COCO](https://cocodataset.org) dataset. 

It is built with
- [VDP](https://github.com/instill-ai/vdp) as the backbone of the Computer Vision (CV) task solver, and
- [Streamlit](https://streamlit.io) as the application framework to build beautiful UI components.

## Preparation
Run VDP locally

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
$ make all
```

 Create two pipelines: `yolov4` and `yolov7` by following the [tutorial](https://blog.instill.tech/vdp-streamlit-yolov4-vs-yolov7).

## How to run the demo
Run the following command
```bash
# Install dependencies
$ pip install -r requirements.txt

# Run the demo
#   --demo-url=< demo URL >
#   --pipeline-backend-base-url=< pipeline backend base URL >
#   --yolov4=< YOLOv4 pipeline ID >
#   --yolov7=< YOLOv7 pipeline ID >
$ streamlit run main.py -- --demo-url=http://localhost:8501 --pipeline-backend-base-url=http://localhost:8081 --yolov4=yolov4 --yolov7=yolov7
```
Now go to `http://localhost:8501/` 🎉

## Deploy the demo using Docker
Build a Docker image
```bash
$ docker build -t streamlit-yolov4-vs-yolov7 .
```
Run the Docker container and connect to VDP 
```bash
$ docker run -p 8501:8501 --network instill-network streamlit-yolov4-vs-yolov7 -- --demo-url=http://localhost:8501 --pipeline-backend-base-url=http://pipeline-backend:8081 --yolov4=yolov4 --yolov7=yolov7

You can now view your Streamlit app in your browser.

  URL: http://0.0.0.0:8501

```
