import argparse
import requests
import json
import cv2
import utils
from typing import List, Tuple
from types import SimpleNamespace
from io import BytesIO
import streamlit as st
import numpy as np
import pandas as pd
from urllib.error import HTTPError


def parse_instance_segmentation_response(resp: requests.Response) ->  Tuple[List[Tuple[float]], List[str], List[str], List[float]]:
    r""" Parse an instance segmentation response in to bounding boxes, RLEs, categories and scores

    Args:
        resp (`requests.Response`): response for standardised instance segmentation task

    Returns: parsed outputs, a tuple of
        List[Tuple[float]]: a list of detected bounding boxes in the format of (top, left, width, height)
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
        for v in r.model_instance_outputs[0].task_outputs[0].instance_segmentation.objects:
            boxes_ltwh.append((
                v.bounding_box.left,
                v.bounding_box.top,
                v.bounding_box.width,
                v.bounding_box.height
            ))
#             rles.append([eval(i) for i in v.rle.split(",")])
            rles.append(v.rle)
            categories.append(v.label)
            scores.append(v.score)

    return boxes_ltwh, rles, categories, scores

def trigger_pipeline(pipeline_backend_base_url: str, pipeline_id: str, file: BytesIO, filename: str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_base_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        file (BytesIO): a bytes object for the input image
        filename (str): file name

    Returns: requests.Response
        pipeline trigger result

    """
    return requests.post("{}/pipelines/{}/trigger-multipart".format(pipeline_backend_base_url, pipeline_id),
                        files=[("file", (filename, file))])

def display_trigger_request_code(pipeline_id, filename):
    r""" Display Trigger request code block
    """
    request_code = f"""
        curl -X POST '{pipeline_backend_base_url}/pipelines/{pipeline_id}/trigger:multipart' \\
        --form 'file=@"{filename}"'
        """
    with st.expander(f"cURL"):
        st.code(request_code, language="bash")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--pipeline-backend-base-url', type=str,
                        default='http://localhost:8081', help='pipeline backend base URL')
    parser.add_argument('--stomata', type=str,
                        default='stomata', help='Stomata instance segmentation pipeline ID on VDP')
    opt = parser.parse_args()
    print(opt)

    pipeline_backend_base_url = opt.pipeline_backend_base_url + "/v1alpha"

    st.set_page_config(page_title="VDP - Identify stomata",
                       page_icon="https://www.instill.tech/favicon-32x32.png", layout="centered", initial_sidebar_state="auto")
    st.markdown("## 🥦 Identify stomata by triggering VDP pipeline")



    # Drag and drop an image as input
    uploaded_file = st.file_uploader("Upload an image", type=([".png", ".jpg", ".jpeg", ".tif", ".tiff"]))
    image_bytes = None
    if uploaded_file:
        image_bytes = uploaded_file.getvalue()
        filename = uploaded_file.name
        arr = np.asarray(bytearray(image_bytes), dtype=np.uint8)
        img_bgr = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        st.image(img)
        st.caption(filename)

        try:
            pipeline_id = opt.stomata
            pipeline_results = []
            display_trigger_request_code(pipeline_id, filename)
            # Trigger VDP pipelines
            resp = trigger_pipeline(
                pipeline_backend_base_url, pipeline_id, image_bytes, filename)

            if resp.status_code == 200:
                # Show trigger pipeline response
                with st.expander(f"POST /pipelines/{pipeline_id}/trigger:multipart response"):
                        st.json(resp.json())

                boxes_ltwh, rles, categories, scores = parse_instance_segmentation_response(resp)
                polys = [utils.rle_to_polygon(rle, box) for rle, box in zip(rles, boxes_ltwh)]
                rotated_boxes = utils.fit_polygens_to_rotated_bboxes(polys)

                cols = st.columns(2)

                cols[0].markdown("#### Display instance segmentation result")
                # Visualise instance segmentation on input image
                img_draw = utils.draw_polygons(img, polys, thickness=2, color=(0,0,255))
                cols[0].image(img_draw)

                # Visualise rotated bounding boxes
                cols[1].markdown("#### Convert to rotated bounding boxes")
                texts = ["{} {:.0%}".format(category, score) for category, score in zip(categories, scores)]
                img_draw = utils.draw_rotated_bboxes(img_draw, rotated_boxes, texts, thickness=2, color=(0,0,255))
                cols[1].image(img_draw)

                # Stomata statistics
                st.markdown(f"""
                #### Stomata statistics

                Detect **{len(rotated_boxes)}** stomata from `{filename}`.
                """)



                stats = np.zeros((len(rotated_boxes), 4))

                for i, (rbox, score) in enumerate(zip(rotated_boxes, scores)):
                    _, (width, height), _ = rbox # (center(x,y), (width, height), angel of rotation)
                    long_axis = max(width, height)
                    short_axis = min(width, height)
                    ratio = long_axis/short_axis
                    stats[i] = [score, long_axis, short_axis, ratio]

                df = pd.DataFrame(
                    stats,
                    columns=("score", "long axis", "short axis", "ratio=long / short axis"))

                score_thres = 0.5
                st.dataframe(df.style.highlight_between(subset="score", left=score_thres, right=1.0), use_container_width=True)

                st.caption(
                    "Note: highlight detections with score >= {}".format(score_thres))


            else:
                st.error("Trigger pipeline {} inference error".format(pipeline_id))

        except (ValueError, HTTPError, requests.ConnectionError) as err:
            st.error("Something wrong with the demo: {}".format(err))
