# YOLOv7 demo

This demo is to showcase using [VDP](https://github.com/instill-ai/vdp) to quickly set up a [YOLOv7](https://github.com/WongKinYiu/yolov7) object detection pipeline. It also uses [Streamlit](https://streamlit.io) to qualitatively compare the detection results with a [YOLOv4](https://github.com/AlexeyAB/darknet) pipeline.

## Preparation
Run VDP locally

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
$ make all
```

 Create two pipelines: `yolov4` and `yolov7` by following the [tutorial](https://blog.instill.tech/vdp-streamlit-yolov7).

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
$ streamlit run main.py -- --demo-url=http://localhost:8501 --pipeline-backend-base-url=http://localhost:8080 --yolov4=yolov4 --yolov7=yolov7
```
Now go to `http://localhost:8501/` 🎉

## Deploy the demo using Docker
Build a Docker image
```bash
$ docker build -t streamlit-yolov7 .
```
Run the Docker container and connect to VDP 
```bash
$ docker run -p 8501:8501 --network instill-network streamlit-yolov7 -- --demo-url=http://localhost:8501 --pipeline-backend-base-url=http://api-gateway:8080 --yolov4=yolov4 --yolov7=yolov7

You can now view your Streamlit app in your browser.

  URL: http://0.0.0.0:8501

```
