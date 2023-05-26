import argparse
import os
import requests
import cv2
import matplotlib.pyplot as plt
import base64

from utils import draw_detection, parse_detection_response

def trigger_pipeline_base64(api_gateway_url: str, pipeline_id: str, img_string:str) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model using remote image URL

    Args:
        api_gateway_url (str): VDP API base URL
        pipeline_id (str): pipeline ID
        image_name (str): local image name, e.g., dog.jpg
        image_path (str): local image path

    Returns: requests.Response
        pipeline trigger result

    """

    body = {
        "task_inputs": [
            {
                "detection": {
                    "image_base64": img_string
                }
            }
        ]
    }

    return requests.post(
        f"{api_gateway_url}/pipelines/{pipeline_id}/triggerSync",
        json=body)

if __name__ == "__main__":

    # Set up args
    parser = argparse.ArgumentParser(description='Trigger SYNC pipeline via base64')
    parser.add_argument("--api-gateway-url", dest = 'api_gateway_url', help = "VDP API URL.",
                        default = 'http://localhost:8080', type = str)
    parser.add_argument("--pipeline-id", dest = 'pipeline_id', help = "Pipeline ID indicates the pipeline to trigger",
                        default = 'vdp-101-sync', type = str)
    parser.add_argument("--image-file", dest = 'image_file', help = "Local image file for object detection",
                        default = 'dog.jpg', type = str)

    opt = parser.parse_args()

    api_gateway_url = opt.api_gateway_url + "/v1alpha"

    img_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), opt.image_file)

    # Convert JPG to base64 format
    with open(img_path, 'rb') as img_file:
        img_string = base64.b64encode(img_file.read()).decode('utf-8')

    # Post HTTP request to the SYNC pipeline
    resp = trigger_pipeline_base64(api_gateway_url, opt.pipeline_id, img_string)

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
    plt.title("Output image with detection results", fontsize=24)

    plt.show()
