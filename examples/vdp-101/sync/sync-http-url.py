import argparse
import requests
import urllib
import cv2
import matplotlib.pyplot as plt
import numpy as np
from urllib.error import HTTPError

from utils import draw_detection, parse_detection_response

def trigger_pipeline_url(api_gateway_url: str, pipeline_id: str, image_url: str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model using remote image URL

    Args:
        api_gateway_url (str): VDP API base URL
        pipeline_id (str): pipeline ID
        image_url (str): remote image URL, e.g., `https://artifacts.instill.tech/imgs/dog.jpg`

    Returns: requests.Response
        pipeline trigger result

    """

    # Prepare JSON Object
    body = {
        "task_inputs": [
            {   
                "detection": {
                    "image_url": image_url
                }
            }
        ]
    }

    return requests.post(
        f"{api_gateway_url}/pipelines/{pipeline_id}/trigger", 
        json=body)

if __name__ == "__main__":

    # Set up args
    parser = argparse.ArgumentParser(description='Trigger SYNC pipeline via URL')
    parser.add_argument("--api-gateway-url", dest = 'api_gateway_url', help = "VDP API base URL",
                        default = 'http://localhost:8080', type = str)
    parser.add_argument("--pipeline-id", dest = 'pipeline_id', help = "A pipeline ID indicates the pipeline to trigger.",
                        default = 'vdp-101-sync', type = str)
    parser.add_argument("--image-url", dest = 'image_url', help = "Image URL for object detection",
                        default = 'https://artifacts.instill.tech/imgs/dog.jpg', type = str)

    opt = parser.parse_args()

    api_gateway_url = opt.api_gateway_url + "/v1alpha"

    # Post HTTP request to the SYNC pipeline
    try:
        resp = trigger_pipeline_url(api_gateway_url, opt.pipeline_id, opt.image_url)
    
    except (ValueError, HTTPError, requests.ConnectionError) as err:
        print("Something wrong with the demo: {}".format(err))
    
    # Parse results from the SYNC pipeline
    boxes_ltwh, categories, scores = parse_detection_response(resp)

    # Print Results
    print(f"boxes ltwh: {boxes_ltwh}, categories: {categories}, scores: {scores}")

    # Show Image
    try:
        # Download image from img_url
        req = urllib.request.Request(opt.image_url, headers={'User-Agent': "XYZ/3.0"})
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
        plt.title("Output image with detection results", fontsize=24)
        
        plt.show()

    except (ValueError, HTTPError, requests.ConnectionError) as err:
        print("Something wrong with the demo: {}".format(err))
