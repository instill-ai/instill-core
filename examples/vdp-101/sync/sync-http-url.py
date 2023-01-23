import argparse
import requests
import urllib
import json
import cv2
import matplotlib.pyplot as plt
import numpy as np
from types import SimpleNamespace
from typing import List, Tuple
from urllib.error import HTTPError

from utils import draw_detection, gen_detection_table

def trigger_pipeline_url(pipeline_backend_url: str, pipeline_id: str, img_url: str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_base_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        image_url (str): remote image URL, e.g., `https://artifacts.instill.tech/imgs/dog.jpg`

    Returns: requests.Response
        pipeline trigger result

    """

    # Prepare JSON Object
    body = {
        "inputs": [
            {
                'image_url': img_url
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
    parser = argparse.ArgumentParser(description='Trigger SYNC pipeline via URL')
    parser.add_argument("--backend", dest = 'pipeline_backend_url', help = "Pipeline backend URL.",
                        default = 'http://localhost:8081/v1alpha', type = str)
    parser.add_argument("--pipeline", dest = 'pipeline_id', help = "A pipeline ID indicates the pipeline to trigger.",
                        default = 'vdp-101-sync', type = str)
    parser.add_argument("--url", dest = 'img_url', help = "File URL for object detection",
                        default = 'https://artifacts.instill.tech/imgs/dog.jpg', type = str)

    opt = parser.parse_args()

    # Post HTTP request to the SYNC pipeline
    try:
        resp = trigger_pipeline_url(opt.pipeline_backend_url, opt.pipeline_id, opt.img_url)
    
    except (ValueError, HTTPError, requests.ConnectionError) as err:
        print("Something wrong with the demo: {}".format(err))
    
    # Parse results from the SYNC pipeline
    boxes_ltwh, categories, scores = parse_detection_response(resp)

    # Print Results
    print(f"boxes ltwh: {boxes_ltwh!r}, categories: {categories}, scores: {scores}")

    # Show Image
    try:
        # Download image from img_url
        req = urllib.request.Request(opt.img_url, headers={'User-Agent': "XYZ/3.0"})
        con = urllib.request.urlopen(req)
        arr = np.asarray(bytearray(con.read()), dtype=np.uint8)
        img_bgr = cv2.imdecode(arr, -1) # 'Load it as it is'
        img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        img_draw = draw_detection(img, boxes_ltwh, categories, scores)

        fig = plt.figure(figsize=(20, 8))

        # Plot input image
        fig.add_subplot(1, 2, 1)
        plt.imshow(img)
        plt.axis('off')
        plt.title("Input image downloaded from URL", fontsize=24)

        # Plot output image
        fig.add_subplot(1, 2, 2)
        plt.imshow(img_draw)
        plt.axis('off')
        plt.title("Output image with detection resutls", fontsize=24)
        
        plt.show()

    except (ValueError, HTTPError, requests.ConnectionError) as err:
        print("Something wrong with the demo: {}".format(err))