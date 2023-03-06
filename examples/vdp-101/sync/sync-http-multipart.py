import argparse
import requests
import cv2
import matplotlib.pyplot as plt

from utils import draw_detection, parse_detection_response

def trigger_pipeline_multipart(pipeline_backend_base_url: str, pipeline_id: str, images: list()) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        images List(str): local image file paths

    Returns: requests.Response
        pipeline trigger result

    """

    body = [("file", (img, open(img, 'rb'))) for img in images]

    return requests.post(
        f"{pipeline_backend_base_url}/pipelines/{pipeline_id}/trigger-multipart", 
        files=body)

if __name__ == "__main__":

    # Set up args
    parser = argparse.ArgumentParser(description='Trigger SYNC pipeline via base64')
    parser.add_argument("--api-gateway-url", dest = 'api_gateway_url', help = "VDP API base URL",
                        default = 'http://localhost:8080', type = str)
    parser.add_argument("--pipeline-id", dest = 'pipeline_id', help = "A pipeline ID indicates the pipeline to trigger.",
                        default = 'vdp-101-sync', type = str)
    parser.add_argument("--image-file", dest = 'image_file', help = "Local image file for object detection",
                        default = 'dog.jpg', type = str)

    opt = parser.parse_args()

    api_gateway_url = opt.api_gateway_url + "/v1alpha"

    # Prepare list of image names to be uploaded as multipart.
    images = [opt.image_file]

    # Post HTTP request to the SYNC pipeline
    resp = trigger_pipeline_multipart(api_gateway_url, opt.pipeline_id, images)

    # Parse results from the SYNC pipeline
    boxes_ltwh, categories, scores = parse_detection_response(resp)

    # Print Results
    print(f"boxes ltwh: {boxes_ltwh!r}, categories: {categories}, scores: {scores}")

    # Show Image
    img_bgr = cv2.imread(opt.image_file, cv2.IMREAD_ANYCOLOR)
    img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    img_draw = draw_detection(img, boxes_ltwh, categories, scores)

    fig = plt.figure(figsize=(20, 8))

    # Plot input image
    fig.add_subplot(1, 2, 1)
    plt.imshow(img)
    plt.axis('off')
    plt.title("Input image as multipart", fontsize=24)

    # Plot output image
    fig.add_subplot(1, 2, 2)
    plt.imshow(img_draw)
    plt.axis('off')
    plt.title("Output image with detection resutls", fontsize=24)
    plt.show()
