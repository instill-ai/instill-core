import argparse
import requests
import json
import cv2
import urllib
import numpy as np
import streamlit as st
from types import SimpleNamespace
from typing import List, Tuple
from urllib.error import HTTPError

from utils import draw_detection, gen_detection_table


def parse_detection_response(resp: requests.Response) -> Tuple[List[Tuple[float]], List[str], List[float]]:
    r""" Parse a detection response in to bounding boxes, categories and scores

    Args:
        resp (`requests.Response`): response for standardised object detection task

    Returns: parsed outputs, a tuple of
        List[Tuple[float]]: a list of detected bounding boxes in the format of (top, left, width, height)
        List[str]: a list of category labels, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.
        List[float]: a list of scores, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.

    """
    if resp.status_code != 200:
        return [], [], []
    else:
        # Parse JSON into an object with attributes corresponding to dict keys.
        r = json.loads(resp.text, object_hook=lambda d: SimpleNamespace(**d))

        boxes_ltwh = []
        categories = []
        scores = []
        for v in r.model_instance_outputs[0].task_outputs[0].detection.objects:
            boxes_ltwh.append((
                v.bounding_box.left,
                v.bounding_box.top,
                v.bounding_box.width,
                v.bounding_box.height))
            categories.append(v.category)
            scores.append(v.score)

        return boxes_ltwh, categories, scores


def trigger_detection_pipeline(pipeline_backend_base_url: str, pipeline_id: str, image_url: str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_base_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        image_url (str): remote image URL, e.g., `https://artifacts.instill.tech/imgs/dog.jpg`

    Returns: requests.Response
        pipeline trigger result

    """
    body = {
        "inputs": [
            {
                'image_url': image_url
            }
        ]
    }

    return requests.post("{}/pipelines/{}/trigger".format(pipeline_backend_base_url, pipeline_id), json=body)


def display_intro_markdown(demo_url="https://demo.instill.tech/yolov4-vs-yolov7"):
    r""" Display Markdown about demo introduction
    """
    st.set_page_config(page_title="VDP - YOLOv4 vs. YOLOv7",
                       page_icon="https://www.instill.tech/favicon-32x32.png", layout="centered", initial_sidebar_state="auto")
    st.image("https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.svg")

    intro_markdown = """

    # YOLOv4 vs. YOLOv7

    [![Twitter](https://img.shields.io/badge/Twitter-%231DA1F2.svg?style=for-the-badge&logo=Twitter&logoColor=white)](https://twitter.com/intent/tweet?hashtags=%2Cvdp%2Cyolov4%2Cyolov7%2Cstreamlit&original_referer=http%3A%2F%2Flocalhost%3A8501%2F&ref_src=twsrc%5Etfw%7Ctwcamp%5Ebuttonembed%7Ctwterm%5Ehashtag%7Ctwgr%5EYOLOv7&text=%F0%9F%94%A5%F0%9F%94%A5%F0%9F%94%A5%20Try%20out%20VDP%20%2B%20YOLOv7%20demo&url={})
    [![Facebook](https://img.shields.io/badge/Facebook-%231877F2.svg?style=for-the-badge&logo=Facebook&logoColor=white)](https://www.facebook.com/sharer/sharer.php?kid_directed_site=0&sdk=joey&u={}&display=popup&ref=plugin&src=share_button)
    [![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/sharing/share-offsite/?url={})

    [Visual Data Preparation (VDP)](https://github.com/instill-ai/vdp) is an open-source visual data ETL tool to streamline the end-to-end visual data processing pipeline

    - 🚀 The fastest way to build end-to-end visual data pipelines
    - 🖱️ One-click import & deploy ML/DL models
    - 🤠 Build for every Vision AI and Data practitioner

    Give us a ⭐ on [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/instill-ai/vdp) and join our [![Discord](https://img.shields.io/badge/Community-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/sevxWsqpGh)

    #### We are offering **FREE** fully-managed VDP on Instill Cloud
    If you are interested in showcasing your models, please [sign up the form](https://www.instill.tech/get-access) and we will reach out to you. Seats are limited - first come , first served.

    # Demo

    To spice things up, we use open-source [VDP](https://github.com/instill-ai/vdp) to import the official [YOLOv4](https://github.com/AlexeyAB/darknet) and [YOLOv7](https://github.com/WongKinYiu/yolov7) models pre-trained with only [MS-COCO](https://cocodataset.org) dataset. VDP instantly gives us the endpoints to perform inference:
    1. https://demo.instill.tech/v1alpha/pipelines/yolov4/trigger
    2. https://demo.instill.tech/v1alpha/pipelines/yolov7/trigger

    Let's trigger two pipelines with an input image each:

    """.format(demo_url, demo_url, demo_url)
    st.markdown(intro_markdown)


def display_vdp_markdown():
    r""" Display Markdown about "What's cool about VDP"
    """
    vdp_markdown = """
    # What's cool about VDP?

    A VDP pipeline unlocks the value of unstructured visual data:

    1. **Extract** unstructured visual data from pre-built data sources such as cloud/on-prem storage, or IoT devices

    2. **Transform** it into analysable structured data by Vision AI models

    3. **Load** the transformed data into warehouses, applications, or other destinations

    With the help of the VDP pipeline, you can start manipulating the data using other structured data tooling in the modern data stack. The results of the above demo will be streamed to the destination data warehouse like:
    """
    st.markdown(vdp_markdown)


def display_trigger_request_code():
    r""" Display Trigger request code block
    """
    request_code = f"""
        curl -X POST '{pipeline_backend_base_url}/pipelines/<pipeline-id>/trigger' \\
        --header 'Content-Type: application/json' \\
        --data-raw '{{
            "inputs": [
                {{
                    "image_url": "{image_url}"
                }}
            ]
        }}'
        """
    with st.expander(f"cURL"):
        st.code(request_code, language="bash")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--demo-url', type=str,
                        default='https://demo.instill.tech/yolov4-vs-yolov7', help='demo URL')
    parser.add_argument('--pipeline-backend-base-url', type=str,
                        default='http://localhost:8081', help='pipeline backend base URL')
    parser.add_argument('--yolov4', type=str,
                        default='yolov4', help='YOLOv4 pipeline ID on VDP')
    parser.add_argument('--yolov7', type=str,
                        default='yolov7', help='YOLOv7 pipeline ID on VDP')
    opt = parser.parse_args()
    print(opt)

    pipeline_backend_base_url = opt.pipeline_backend_base_url + "/v1alpha"

    display_intro_markdown(opt.demo_url)

    # Use image remote URL to fetch an image in input
    image_url = st.text_input(
        label="Feed me with an image URL and press ENTER", value="https://artifacts.instill.tech/imgs/dog.jpg")

    try:
        # Trigger VDP pipelines
        pipeline_ids = [opt.yolov4, opt.yolov7]
        pipeline_results = []
        for pipeline_id in pipeline_ids:
            resp = trigger_detection_pipeline(
                pipeline_backend_base_url, pipeline_id, image_url)
            boxes_ltwh, categories, scores = parse_detection_response(resp)
            pipeline_results.append((resp, boxes_ltwh, categories, scores))

        # Visualise the input image
        req = urllib.request.Request(
            image_url, headers={'User-Agent': "XYZ/3.0"})
        con = urllib.request.urlopen(req, timeout=10)
        arr = np.asarray(bytearray(con.read()), dtype=np.uint8)
        img_bgr = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        _, col, _ = st.columns([0.2, 0.6, 0.2])
        col.image(img, use_column_width=True,
                  caption=f"Image source: {image_url}")

        """
        #### Results

        Spot any difference?
        """

        # Visualise detections on input image
        cols = st.columns(len(pipeline_ids))
        captions = ["YOLOv4", "YOLOv7"]
        for col, (resp, boxes_ltwh, categories, scores), cap in zip(cols, pipeline_results, captions):
            if resp.status_code == 200:
                # Show image overlaid with detection results
                img_draw = draw_detection(img, boxes_ltwh, categories, scores)
                col.image(img_draw, use_column_width=True, caption=cap)
            else:
                col.error("{} inference error".format(cap))

        # Show request to trigger the pipeline (full column)
        display_trigger_request_code()
        # Show response for each pipeline
        cols = st.columns(len(pipeline_ids))
        for col, (resp, _, _, _) in zip(cols, pipeline_results):
            if resp.status_code == 200:
                with col.expander(f"POST /pipelines/{pipeline_id}/trigger response"):
                    st.json(resp.json())

        # Display VDP markdown (full column)
        display_vdp_markdown()
        # Display detections with scores >= 0.5 in a table
        cols = st.columns(len(pipeline_ids))
        detection_thres = 0.5
        for col, (resp, boxes_ltwh, categories, scores) in zip(cols, pipeline_results):
            if resp.status_code == 200:
                _, df = gen_detection_table(
                    boxes_ltwh, categories, scores)
                if len(df):
                    col.dataframe(df.style.highlight_between(
                        subset='Score', left=detection_thres, right=1.0))
                else:
                    col.dataframe(df)
        st.caption(
            "Highlight detections with score >= {}".format(detection_thres))

    except (ValueError, HTTPError, requests.ConnectionError) as err:
        st.error("Something wrong with the demo: {}".format(err))
        display_vdp_markdown()
