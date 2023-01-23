import argparse
import os
import requests
import json
import cv2
import matplotlib.pyplot as plt
import base64
from types import SimpleNamespace
from typing import List, Tuple

from utils import draw_detection, gen_detection_table

def trigger_pipeline_base64(pipeline_backend_url: str, pipeline_id: str, img_string:str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_base_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        image_name (str): local image name, e.g., dog.jpg
        image_path (str): local image path

    Returns: requests.Response
        pipeline trigger result

    """

    body = {
        "inputs": [
            {
                "image_base64": img_string
            }
        ]
    }

    return requests.post(
        f"{pipeline_backend_url}/pipelines/{pipeline_id}/trigger", 
        json=body)


def parse_detection_response(resp: requests.Response) -> Tuple[List[Tuple[float]], List[str], List[float]]:
    r""" Parse a detection response in to bounding boxes, categories and scores

    Args:
        resp (`requests.Response`): response for standardised object detection task

    Returns: parsed outputs, a tuple of
        List[Tuple[float]]: a list of detected bounding boxes in the format of (left, top, width, height)
        List[str]: a list of category labels, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.
        List[float]: a list of scores, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.

    """

    boxes_ltwh = []
    categories = []
    scores = []

    if resp.status_code != 200:
        print('Pipeline respondes with erorr code: ', resp.status_code)
    else:
        # Parse JSON into an object with attributes corresponding to dict keys.
        r = json.loads(resp.text, object_hook=lambda d: SimpleNamespace(**d))

        for v in r.model_instance_outputs[0].task_outputs[0].detection.objects:
            boxes_ltwh.append((
                v.bounding_box.left,
                v.bounding_box.top,
                v.bounding_box.width,
                v.bounding_box.height))
            categories.append(v.category)
            scores.append(v.score)

    return boxes_ltwh, categories, scores

if __name__ == "__main__":

    # Set up args
    parser = argparse.ArgumentParser(description='Trigger SYNC pipeline via base64')
    parser.add_argument("--backend", dest = 'pipeline_backend_url', help = "Pipeline backend URL.",
                        default = 'http://localhost:8081/v1alpha', type = str)
    parser.add_argument("--pipeline", dest = 'pipeline_id', help = "Pipeline ID indicatees the pipeline that is going to be triggered.",
                        default = 'vdp-101-sync', type = str)
    parser.add_argument("--image", dest = 'img_name', help = "File for object detection",
                        default = 'dog.jpg', type = str)

    opt = parser.parse_args()
    
    img_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), opt.img_name)

    # Convert JPG to base64 format
    with open(img_path, 'rb') as img_file:
        img_string = base64.b64encode(img_file.read()).decode('utf-8')

    # Post HTTP request to the SYNC pipeline
    resp = trigger_pipeline_base64(opt.pipeline_backend_url, opt.pipeline_id, img_string)

    # Parse results from the SYNC pipeline
    boxes_ltwh, categories, scores = parse_detection_response(resp)

    # Print Results
    print(f"boxes ltwh: {boxes_ltwh!r}, categories: {categories}, scores: {scores}")

    # Show Image
    img_bgr = cv2.imread(img_path, cv2.IMREAD_ANYCOLOR)
    img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    img_draw = draw_detection(img, boxes_ltwh, categories, scores)

    fig = plt.figure(figsize=(20, 8))

    # Plot input image
    fig.add_subplot(1, 2, 1)
    plt.imshow(img)
    plt.axis('off')
    plt.title("Input image in the local folder", fontsize=24)

    # Plot output image
    fig.add_subplot(1, 2, 2)
    plt.imshow(img_draw)
    plt.axis('off')
    plt.title("Output image with detection resutls", fontsize=24)
    
    plt.show()