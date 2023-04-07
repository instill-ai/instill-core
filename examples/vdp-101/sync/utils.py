
import random
import cv2
import requests
import json
from enum import Enum
from types import SimpleNamespace
from typing import List, Tuple


class COCOLabels(Enum):
    PERSON = 0
    BICYCLE = 1
    CAR = 2
    MOTORBIKE = 3
    AEROPLANE = 4
    BUS = 5
    TRAIN = 6
    TRUCK = 7
    BOAT = 8
    TRAFFIC_LIGHT = 9
    FIRE_HYDRANT = 10
    STOP_SIGN = 11
    PARKING_METER = 12
    BENCH = 13
    BIRD = 14
    CAT = 15
    DOG = 16
    HORSE = 17
    SHEEP = 18
    COW = 19
    ELEPHANT = 20
    BEAR = 21
    ZEBRA = 22
    GIRAFFE = 23
    BACKPACK = 24
    UMBRELLA = 25
    HANDBAG = 26
    TIE = 27
    SUITCASE = 28
    FRISBEE = 29
    SKIS = 30
    SNOWBOARD = 31
    SPORTS_BALL = 32
    KITE = 33
    BASEBALL_BAT = 34
    BASEBALL_GLOVE = 35
    SKATEBOARD = 36
    SURFBOARD = 37
    TENNIS_RACKET = 38
    BOTTLE = 39
    WINE_GLASS = 40
    CUP = 41
    FORK = 42
    KNIFE = 43
    SPOON = 44
    BOWL = 45
    BANANA = 46
    APPLE = 47
    SANDWICH = 48
    ORANGE = 49
    BROCCOLI = 50
    CARROT = 51
    HOT_DOG = 52
    PIZZA = 53
    DONUT = 54
    CAKE = 55
    CHAIR = 56
    SOFA = 57
    POTTEDPLANT = 58
    BED = 59
    DININGTABLE = 60
    TOILET = 61
    TVMONITOR = 62
    LAPTOP = 63
    MOUSE = 64
    REMOTE = 65
    KEYBOARD = 66
    CELL_PHONE = 67
    MICROWAVE = 68
    OVEN = 69
    TOASTER = 70
    SINK = 71
    REFRIGERATOR = 72
    BOOK = 73
    CLOCK = 74
    VASE = 75
    SCISSORS = 76
    TEDDY_BEAR = 77
    HAIR_DRIER = 78
    TOOTHBRUSH = 79


random.seed(0)
COLORS = [[random.randint(0, 255) for _ in range(3)] for _ in COCOLabels]


def get_label_color(label: str) -> List[int]:
    r""" Get the corresponding color of a pre-defined COCO category

    Args:
        label (str): COCO category label

    Returns: List[int]
        category color in the format [R, G, B]

    """
    category_idx = COCOLabels[label.upper()].value - 1
    return COLORS[category_idx]

def parse_detection_response(resp: requests.Response) -> Tuple[List[Tuple[float]], List[str], List[float]]:
    r""" Parse a detection response in to bounding boxes, categories and scores

    Args:
        resp (`requests.Response`): response for standardised object Detection task

    Returns: parsed outputs, a tuple of
        List[Tuple[float]]: a list of detected bounding boxes in the format of (left, top, width, height)
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
        for v in r.model_outputs[0].task_outputs[0].detection.objects:
            boxes_ltwh.append((
                v.bounding_box.left,
                v.bounding_box.top,
                v.bounding_box.width,
                v.bounding_box.height))
            categories.append(v.category)
            scores.append(v.score)

        return boxes_ltwh, categories, scores

def draw_detection(img: cv2.Mat, boxes_ltwh: List[Tuple[float]], categories: List[str], scores: List[float], line_thickness=3) -> cv2.Mat:
    r""" Draw detection results on an image

    Args:
        img (cv2.Mat): the original image
        boxes_ltwh (List[Tuple[float]]): a list of detected bounding boxes in the format of (left, top, width, height)
        categories (List[str]): a list of category labels, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.
        scores (List[float]]): a list of scores, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.

    Returns: cv2.Mat
        the image overlaid with detection results

    """
    img_draw = img.copy()

    tl = line_thickness
    tf = max(tl-1, 1)
    for box, label, score in zip(boxes_ltwh, categories, scores):
        left, top, width, height = box
        x1, y1, x2, y2 = left, top, left + width, top + height
        c1, c2 = (int(x1), int(y1)), (int(x2), int(y2))
        color = get_label_color(label)

        text = f"{label} {score:.2f}"

        img_draw = cv2.rectangle(
            img_draw, c1, c2, color, thickness=tl, lineType=cv2.LINE_AA)

        t_size = cv2.getTextSize(
            text, 0, fontScale=tl / 3, thickness=tf)[0]
        c2 = c1[0] + t_size[0], c1[1] - t_size[1] - 3
        img_draw = cv2.rectangle(
            img_draw, c1, c2, color, -1, cv2.LINE_AA)  # filled
        img_draw = cv2.putText(
            img_draw, text, (c1[0], c1[1] - 2), 0, tl / 3,
            [225, 255, 255], thickness=tf, lineType=cv2.LINE_AA)

    return img_draw
