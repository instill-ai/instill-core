import argparse
import requests
import json
import cv2
import urllib
import utils
import streamlit as st
import numpy as np
from typing import List, Tuple
from types import SimpleNamespace
from urllib.error import HTTPError


def parse_instance_segmentation_response(resp: requests.Response) ->  Tuple[List[Tuple[float]], List[str], List[str], List[float]]:
    r""" Parse an instance segmentation response in to bounding boxes, RLEs, categories and scores

    Args:
        resp (`requests.Response`): response for standardised instance segmentation task

    Returns: parsed outputs, a tuple of
        List[Tuple[float]]: a list of detected bounding boxes in the format of (left, top, width, height)
        List[str]: a list of Uncompressed Run-length encoding (RLE) in the format of comma separated string separated by comma. The length of this list must be the same as the detected bounding boxes.
        List[str]: a list of category labels, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.
        List[float]: a list of scores, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.

    """
    if resp.status_code != 200:
        return [], [], [], []
    else:
        # Parse JSON into an object with attributes corresponding to dict keys.
        r = json.loads(resp.text, object_hook=lambda d: SimpleNamespace(**d))

        boxes_ltwh, rles, categories, scores = [], [], [], []
        for output in r.model_instance_outputs[0].task_outputs:
            for v in output.instance_segmentation.objects:
                boxes_ltwh.append((
                    v.bounding_box.left,
                    v.bounding_box.top,
                    v.bounding_box.width,
                    v.bounding_box.height
                ))
                rles.append(v.rle)
                categories.append(v.category)
                scores.append(v.score)

    return boxes_ltwh, rles, categories, scores

def trigger_pipeline(pipeline_backend_base_url: str, pipeline_id: str, image_url: str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_base_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        image_url (str): remote image URL, e.g., `https://artifacts.instill.tech/imgs/dog.jpg`

    Returns: requests.Response
        pipeline trigger result

    """
    body = {
        "task_inputs": [
            {
                "instance_segmentation": {
                    'image_url': image_url
                }
            }
        ]
    }

    return requests.post("{}/pipelines/{}/trigger".format(pipeline_backend_base_url, pipeline_id), json=body)

def display_intro_markdown(pipeline_id="inst"):
    r""" Display Markdown about demo introduction
    """

    st.set_page_config(page_title="VDP - Instance segmentation",
                       page_icon="https://www.instill.tech/favicon-32x32.png", layout="centered", initial_sidebar_state="auto")
    st.image("https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.svg")

    intro_markdown = """

    # Instance segmentation by triggering VDP pipeline

    [Visual Data Preparation (VDP)](https://github.com/instill-ai/vdp) is an open-source unstructured data ETL tool to streamline the end-to-end unstructured data processing pipeline

    - 🚀 The fastest way to build end-to-end unstructured data pipelines
    - 🖱️ One-click import & deploy ML/DL models
    - 🤠 Build for every Vision AI and Data practitioner

    Give us a ⭐ on [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/instill-ai/vdp) and join our [![Discord](https://img.shields.io/badge/Community-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/sevxWsqpGh)

    #### We are offering **FREE** fully-managed VDP on Instill Cloud
    If you are interested in showcasing your models, please [sign up the form](https://www.instill.tech/get-access) and we will reach out to you. Seats are limited - first come , first served.

    # Demo

    We use open-source [VDP](https://github.com/instill-ai/vdp) to import the [Mask R-CNN](https://github.com/instill-ai/model-instance-segmentation-dvc) model pre-trained on COCO dataset.

    VDP instantly gives us the endpoint to perform inference: `https://demo.instill.tech/v1alpha/pipelines/{}/trigger`


    """.format(pipeline_id)
    st.markdown(intro_markdown)

def display_vdp_markdown():
    r""" Display Markdown about "What's cool about VDP"
    """
    vdp_markdown = """
    # What's cool about VDP?

    A VDP pipeline unlocks the value of unstructured data:

    1. **Extract** unstructured data from pre-built data sources such as cloud/on-prem storage, or IoT devices

    2. **Transform** it into analysable structured data by Vision AI models

    3. **Load** the transformed data into warehouses, applications, or other destinations

    With the help of the VDP pipeline, you can start manipulating the data using other structured data tooling in the modern data stack.
    """
    st.markdown(vdp_markdown)


def display_trigger_request_code(pipeline_id):
    r""" Display Trigger request code block
    """
    request_code = f"""
        curl -X POST '{pipeline_backend_base_url}/pipelines/{pipeline_id}/trigger' \\
        --header 'Content-Type: application/json' \\
        --data-raw '{{
            "task_inputs": [
                {{
                    "instance_segmentation": {{
                        "image_url": "{image_url}"
                    }}
                }}
            ]
        }}'
        """
    with st.expander(f"cURL"):
        st.code(request_code, language="bash")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--pipeline-backend-base-url', type=str,
                        default='http://localhost:8080', help='pipeline backend base URL')
    parser.add_argument('--pipeline-id', type=str,
                        default='inst', help='Instance segmentation pipeline ID on VDP')
    opt = parser.parse_args()
    print(opt)

    pipeline_backend_base_url = opt.pipeline_backend_base_url + "/v1alpha"

    display_intro_markdown()

    # Use image remote URL to fetch an image in input
    image_url = st.text_input(
        label="Feed me with an image URL and press ENTER", value="https://artifacts.instill.tech/imgs/dog.jpg")

    try:
        req = urllib.request.Request(
            image_url, headers={'User-Agent': "XYZ/3.0"})
        con = urllib.request.urlopen(req, timeout=10)
        arr = np.asarray(bytearray(con.read()), dtype=np.uint8)
        img_bgr = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        img_height, img_width = img.shape[:2]

        pipeline_id = opt.pipeline_id
        pipeline_results = []
        # Trigger VDP pipelines
        resp = trigger_pipeline(
            pipeline_backend_base_url, pipeline_id, image_url)

        if resp.status_code == 200:
            boxes_ltwh, rles_str, categories, scores = parse_instance_segmentation_response(resp)
            masks = [utils.rle_decode_original_image(rle_str, box, (img_height, img_width)) for rle_str, box in zip(rles_str, boxes_ltwh)]
            masks = np.asarray(masks, dtype=np.uint8)

            cols = st.columns(2)
            # Visualize the input image
            cols[0].markdown("#### Original image")
            texts = ["{} {:.0%}".format(category, score) for category, score in zip(categories, scores)]
            cols[0].image(img)

            cols[1].markdown("#### Instance segmentation")
            # Visualize instance segmentation on input image
            img_draw = utils.draw_instance_predictions(img, masks, np.asarray(boxes_ltwh, dtype=np.float32), texts)
            cols[1].image(img_draw)

            # Display instance segmentation in a table
            score_thres = 0.5
            _, df = utils.generate_instance_prediction_table(categories, scores)
            if len(df):
                st.dataframe(df.style.highlight_between(subset="score", left=score_thres, right=1.0), use_container_width=True)
                st.caption(
                    "Note: highlight instances with score >= {}".format(score_thres))

            display_trigger_request_code(pipeline_id)
            # Show trigger pipeline response
            with st.expander(f"POST /pipelines/{pipeline_id}/trigger response"):
                    st.json(resp.json())

        else:
            st.error("Trigger pipeline {} inference error".format(pipeline_id))

    except (ValueError, HTTPError, requests.ConnectionError) as err:
        st.error("Something wrong with the demo: {}".format(err))

    display_vdp_markdown()
