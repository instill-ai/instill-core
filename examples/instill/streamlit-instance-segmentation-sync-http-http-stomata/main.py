import argparse
import requests
import json
import cv2
import utils
import streamlit as st
import numpy as np
import pandas as pd
from typing import List, Tuple
from types import SimpleNamespace
from io import BytesIO
from urllib.error import HTTPError


def parse_instance_segmentation_response(resp: requests.Response) -> Tuple[List[Tuple[float]], List[str], List[str], List[float]]:
    r""" Parse an Instance Segmentation response in to bounding boxes, RLEs, categories and scores

    Args:
        resp (`requests.Response`): response for standardised Instance Segmentation task

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
    #             rles.append([eval(i) for i in v.rle.split(",")])
                rles.append(v.rle)
                categories.append(v.category)
                scores.append(v.score)

    return boxes_ltwh, rles, categories, scores


@st.cache_data(max_entries=10)
def trigger_pipeline(api_gateway_url: str, pipeline_id: str, file: BytesIO, filename: str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        api_gateway_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        file (BytesIO): a bytes object for the input image
        filename (str): file name

    Returns: requests.Response
        pipeline trigger result

    """
    return requests.post("{}/pipelines/{}/trigger-multipart".format(api_gateway_url, pipeline_id),
                         files=[("file", (filename, file))])


def display_intro_markdown(pipeline_id="stomata"):
    r""" Display Markdown about demo introduction
    """

    st.set_page_config(page_title="VDP - Stomata Instance Segmentation",
                       page_icon="https://www.instill.tech/favicon-32x32.png", layout="centered", initial_sidebar_state="auto")
    st.image("https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.svg")

    intro_markdown = """

    # 🥦 Identify stomata by triggering VDP pipeline

    [Versatile Data Pipeline (VDP)](https://github.com/instill-ai/vdp) is an open-source unstructured data ETL tool to streamline end-to-end unstructured data processing

    - 🚀 The fastest way to build end-to-end unstructured data pipelines
    - 🖱️ One-click import & deploy ML/DL models
    - 🤠 Built for every AI and Data practitioner

    Give us a ⭐ on [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/instill-ai/vdp) and join our [![Discord](https://img.shields.io/badge/Community-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/sevxWsqpGh)

    #### We are offering **FREE** fully-managed VDP on Instill Cloud
    If you are interested in showcasing your models, please [sign up the form](https://www.instill.tech/get-access) and we will reach out to you. Seats are limited - first come , first served.

    # Demo

    We use open-source [VDP](https://github.com/instill-ai/vdp) to import an [Instance Segmentation model](https://github.com/instill-ai/model-stomata-instance-segmentation-dvc) fine-tuned on the Stomata dataset collected by [the Agricultural Biotechnology Research Center (ABRC) of Academia Sinica](https://abrc.sinica.edu.tw/faculty/?id=yalin).

    VDP instantly gives us the endpoint to perform inference: `https://demo.instill.tech/v1alpha/pipelines/{}/trigger:multipart`


    """.format(pipeline_id)
    st.markdown(intro_markdown)


def display_vdp_markdown():
    r""" Display Markdown about "What's cool about VDP"
    """
    vdp_markdown = """
    # What's cool about VDP?

    A VDP pipeline unlocks the value of unstructured data:

    1. **Extract** unstructured data from pre-built data sources such as cloud/on-prem storage, or IoT devices

    2. **Transform** it into meaningful data representations by AI models

    3. **Load** the transformed data into warehouses, applications, or other destinations

    With the help of the VDP pipeline, you can start manipulating the data using other data tooling in the modern data stack.
    """
    st.markdown(vdp_markdown)


def display_trigger_request_code(pipeline_id, filename):
    r""" Display Trigger request code block
    """
    request_code = f"""
        curl -X POST '{api_gateway_url}/pipelines/{pipeline_id}/trigger:multipart' \\
        --form 'file=@"{filename}"'
        """
    with st.expander(f"cURL"):
        st.code(request_code, language="bash")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--api-gateway-url', type=str,
                        default='http://localhost:8080', help='VDP API base URL')
    parser.add_argument('--pipeline-id', type=str,
                        default='stomata', help='Stomata Instance Segmentation pipeline ID on VDP')
    opt = parser.parse_args()
    print(opt)

    api_gateway_url = opt.api_gateway_url + "/v1alpha"

    display_intro_markdown(opt.pipeline_id)

    st.markdown("We provide an sample image below:")
    filename = "sample.jpg"
    with open(filename, "rb") as f:
        buf = BytesIO(f.read())
        image_bytes = buf.getvalue()

    # Drag and drop an image as input
    uploaded_file = st.file_uploader("Upload an image", type=(
        [".png", ".jpg", ".jpeg", ".tif", ".tiff"]))
    if uploaded_file is not None:
        filename = uploaded_file.name
        image_bytes = uploaded_file.getvalue()

    arr = np.asarray(bytearray(image_bytes), dtype=np.uint8)
    img_bgr = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)

    st.image(img)
    st.caption(filename)

    try:
        pipeline_id = opt.pipeline_id
        pipeline_results = []
        display_trigger_request_code(pipeline_id, filename)
        # Trigger VDP pipelines
        resp = trigger_pipeline(
            api_gateway_url, pipeline_id, image_bytes, filename)

        if resp.status_code == 200:
            # Show trigger pipeline response
            with st.expander(f"POST /pipelines/{pipeline_id}/trigger:multipart response"):
                st.json(resp.json())

            boxes_ltwh, rles_str, categories, scores = parse_instance_segmentation_response(
                resp)
            # Convert RLE from string "n1,n2,n3,..." to COCO RLE
            #   {
            #       'counts': [n1, n2, n3, ...],
            #       'size': [height, width] of the mask
            #   }
            rles = [{'counts': rle_str.split(","), 'size': [
                bbox_ltwh[3], bbox_ltwh[2]]} for rle_str, bbox_ltwh in zip(rles_str, boxes_ltwh)]
            polys = [utils.rle_to_polygon(rle, box)
                     for rle, box in zip(rles, boxes_ltwh)]
            rotated_boxes = utils.fit_polygens_to_rotated_bboxes(polys)

            cols = st.columns(2)

            cols[0].markdown("#### Display Instance Segmentation result")
            # Visualise Instance Segmentation on input image
            img_draw = utils.draw_polygons(
                img, polys, thickness=2, color=(0, 0, 255))
            cols[0].image(img_draw)

            # Visualise rotated bounding boxes
            cols[1].markdown("#### Convert to rotated bounding boxes")
            texts = ["{} {:.0%}".format(category, score)
                     for category, score in zip(categories, scores)]
            img_draw = utils.draw_rotated_bboxes(
                img_draw, rotated_boxes, texts, thickness=2, color=(0, 0, 255))
            cols[1].image(img_draw)

            # Stomata statistics
            st.markdown(f"""
            #### Stomata statistics

            Detect **{len(rotated_boxes)}** stomata from `{filename}`.
            """)

            stats = np.zeros((len(rotated_boxes), 4))

            for i, (rbox, score) in enumerate(zip(rotated_boxes, scores)):
                # (center(x,y), (width, height), angel of rotation)
                _, (width, height), _ = rbox
                long_axis = max(width, height)
                short_axis = min(width, height)
                ratio = short_axis/long_axis
                stats[i] = [score, short_axis, long_axis, ratio]

            df = pd.DataFrame(
                stats,
                columns=("score", "short axis", "long axis", "ratio = short / long axis"))

            score_thres = 0.5
            st.dataframe(df.style.highlight_between(
                subset="score", left=score_thres, right=1.0), use_container_width=True)

            st.caption(
                "Note: highlight detections with score >= {}".format(score_thres))

        else:
            st.error("Trigger pipeline {} inference error: {}".format(
                pipeline_id, resp.text))

    except (ValueError, HTTPError, requests.ConnectionError) as err:
        st.error("Something wrong with the demo: {}".format(err))

    display_vdp_markdown()