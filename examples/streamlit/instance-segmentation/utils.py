import cv2
import random
import numpy as np
import pandas as pd
import streamlit as st
from itertools import groupby
from typing import List, Tuple
from pycocotools import mask as cocomask

random.seed(0)

def random_color():
    r""" Get random color

    Returns List[int] a random RGB color with values between [0, 255]
    """
    return [random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)]

def rle_encode(binary_mask: np.ndarray):
    r""" Encode binary mask into uncompressed Run-length Encoding (RLE) in COCO format

    Args:
        binary_mask (np.ndarray): a binary mask with the shape of `mask_shape`

    Returns uncompressed RLE in COCO format
            Link: https://github.com/cocodataset/cocoapi/blob/master/PythonAPI/pycocotools/mask.py
            {
                'counts': [n1, n2, n3, ...],
                'size': [height, width] of the mask
            }
    """
    fortran_binary_mask = np.asfortranarray(binary_mask)
    uncompressed_rle = {'counts': [], 'size': list(binary_mask.shape)}
    counts = uncompressed_rle.get('counts')
    for i, (value, elements) in enumerate(groupby(fortran_binary_mask.ravel(order='F'))):
        if i == 0 and value == 1:
            counts.append(0)    # Add 0 if the mask starts with one, since the odd counts are always the number of zeros
        counts.append(len(list(elements)))

    return uncompressed_rle

def rle_decode(uncompressed_rle: dict):
    r""" Decode uncompressed Run-length Encoding (RLE) in COCO format into binary mask

    Args:
        uncompressed_rle: uncompressed Run-length Encoding (RLE) in COCO format
            Link: https://github.com/cocodataset/cocoapi/blob/master/PythonAPI/pycocotools/mask.py
            {
                'counts': [n1, n2, n3, ...],
                'size': [height, width] of the mask
            }

    Returns np.ndarray binary mask (uint8), 1 - mask, 0 - background
    """
    if len(uncompressed_rle.get('size')) != 2:
        return None

    height, width = uncompressed_rle.get('size')
    compressed_rle = cocomask.frPyObjects(uncompressed_rle, height, width)
    return cocomask.decode(compressed_rle)

def rle_decode_original_image(rle_str: str, bbox_ltwh: Tuple[float], image_size: Tuple[int]):
    r""" Decode VDP standardized instance segmentation result into a binary mask of the original image shape

    Args:
        rle_str (str): uncompressed Run-length Encoding (RLE), a variable-length comma-delimited string "n1,n2,n3,..."
        bbox_ltwh (Tuple[float]): the bounding box containing the mask in the format of (left, top, width, height)
        image_shape (Tuple[int]): (height,width) of the original image

    Returns np.ndarray binary mask with the original image size, 1 - mask, 0 - background
    """
    l, t, w, h = bbox_ltwh
    # Convert RLE from string "n1,n2,n3,..." to COCO RLE
    #   {
    #       'counts': [n1, n2, n3, ...],
    #       'size': [height, width] of the mask
    #   }
    uncompressed_rle = {'counts': rle_str.split(","), 'size': [h, w]}

    mask = rle_decode(uncompressed_rle)
    # Put mask into original image size https://cdn2.psychologytoday.com/assets/styles/manual_crop_1_91_1_1528x800/public/field_blog_entry_teaser_image/2022-11/happy_dog_ammit_square.png
    img_h, img_w = image_size
    img_mask = np.zeros((img_h, img_w), dtype=mask.dtype)
    # Avoid border overflow
    x1, x2, y1,y2 = max(0,l), min(l+w, img_w), max(0,t), min(t+h, img_h)
    img_mask[y1:y2, x1:x2] = mask[0:y2-y1, 0:x2-x1]
    return img_mask

@st.cache_data(max_entries=10)
def draw_instance_predictions(img: np.ndarray, masks: np.ndarray, boxes: np.ndarray, texts: List[str]):
    r""" Draw instance segmentation results on the original image

    Args:
        img (np.ndarray): image to be drawn
        mask (np.ndarray): detected instance masks with shape (num_instances, )
        boxes (np.ndarray): detected bounding boxes with shape (num_instances, ) and bounding box format (left, top, width, height)
        texts (List[str]): a list of texts displayed with the corresponding bounding boxes

    Returns np.ndarray instance segmentation results drawn on the image
    """
    num_instances = len(masks)
    assert len(boxes) == num_instances and len(texts) == num_instances

    for m in masks:
        assert m.shape[:2] == img.shape[:2]

    if num_instances == 0:
        return img

    img_height, img_width = img.shape[:2]

    masks = [GenericMask(x, img_height, img_width) for x in masks]
    assigned_colors = [random_color() for _ in range(num_instances)]

    # Display in largest to smallest order to reduce occlusion
    areas = np.prod(boxes[:,2:],axis=1)
    sorted_idxs = np.argsort(-areas).tolist()
    masks = [masks[idx] for idx in sorted_idxs]
    boxes = [boxes[k] for k in sorted_idxs]
    texts = [texts[k] for k in sorted_idxs]
    assigned_colors = [assigned_colors[k] for k in sorted_idxs]

    for box, text, mask, color in zip(boxes, texts, masks, assigned_colors):
        img = draw_box(img, box, color=color,  thickness=1)
        text_pos = (int(box[0]), int(box[1]))  # if drawing boxes, put text on the box corner

        for polygon in mask.polygons:
            img = draw_polygon(img, polygon, color=color, thickness=1)
        img = draw_text(img, text, text_pos, color=color, thickness=2)

    return img

def draw_box(img: np.ndarray, box_ltwh: np.ndarray, color: List[int], thickness:int=1):
    r""" Draw bounding box on an image

    Args:
        img (np.ndarray): image to be drawn
        box_ltwh (np.ndarray): a bounding box with format (left, top, width, height)
        color (List[int]): bounding box color [R, G, B]
        thickness (int): bounding box edge line thickness, default = 1

    Returns np.ndarray bounding box drawn on the image
    """
    img_draw = img.copy()
    l, t, width, height = box_ltwh
    c1, c2 = (int(l), int(t)), (int(l+width), int(t+height))
    img_draw = cv2.rectangle(
        img_draw, c1, c2, color, thickness=thickness, lineType=cv2.LINE_AA)
    return img_draw

def draw_text(img: np.ndarray, text: str, position: Tuple[int], color:List[int]=[255,255,255], thickness:int=1):
    r""" Draw text on an image

    Args:
        img (np.ndarray): image to be drawn
        text (str): text to draw on the image
        position (Tuple[int]): text drawn position (x, y)
        color (List[int]): bounding box color [R, G, B]
        thickness (int): bounding box edge line thickness, default = 1

    Returns np.ndarray bounding box drawn on the image
    """
    img_draw = img.copy()
    color = np.maximum(list(color), 51)
    color[np.argmax(color)] = max(204, np.max(color))

    tl = thickness
    tf= max(tl-1, 1)
    c1 = (int(position[0]), int(position[1]))
    t_size = cv2.getTextSize(
            text, 0, fontScale=tl / 3, thickness=tf)[0]
    c2 = (max(c1[0] + t_size[0], 0), max(c1[1] - t_size[1] - 3, 0))
    c1 = (c2[0]-t_size[0], c2[1]+t_size[1]+3)

    img_draw = cv2.rectangle(
            img_draw, c1, c2, [0, 0, 0], -1, cv2.LINE_AA)  # filled
    img_draw = cv2.putText(
            img_draw, text, (c1[0], c1[1] - 2), 0, tl / 3,
            color=[int(c) for c in color], thickness=tf, lineType=cv2.LINE_AA)

    return img_draw

def draw_polygon(img: np.ndarray, polygon: List[float], color:List[int], thickness:int=1, alpha:float=0.8):
    r""" Draw polygon on an image

    Args:
        img (np.ndarray): image to be drawn
        polygon (): polygon to draw on the image in the format of [x1, y1, x2, y2, ...]
        color (List[int]): bounding box color [R, G, B]
        thickness (int): bounding box edge line thickness, default = 1
        alpha (float):  the larger it is, the more opaque the segmentation is, default = 0.8

    Returns np.ndarray polygon drawn on the image
    """
    img_ = img.copy()
    pts_x = polygon[::2]
    pts_y = polygon[1::2]
    pts = [[x, y] for x,y in zip(pts_x, pts_y)]
    pts = np.array(pts, np.int32)
    img_poly = cv2.polylines(img_, [pts], isClosed=True, thickness=thickness, color=color)

    overlay = img_poly.copy()
    # Draw filled polygon
    overlay = cv2.fillPoly(overlay, [pts], color=color)
    img = cv2.addWeighted(overlay, alpha, img_poly, 1-alpha, 0)

    return img

def generate_instance_prediction_table(categories: List[str], scores: List[float]):
    r""" Generate instance prediction data frame

    Args:

    Returns: a tuple of
        bool: flag to indicate whether the inputs are valid
        pd.DataFrame: generated data frame
    """
    if len(categories) != len(scores):
        return False, pd.DataFrame(data)
    data = {
                "category": [],
                "score": []
            }
    for category, score in zip(categories, scores):
        data["category"].append(category)
        data["score"].append(score)

    return True, pd.DataFrame(data)

class GenericMask:
    r""" Revised from Detectron2 https://github.com/facebookresearch/detectron2/blob/e39b8d0e6a5d17f713b20061b9cfc30f92213a5a/detectron2/utils/visualizer.py#L59-L152

    Attribute:
        polygons (list[np.ndarray]): list[np.ndarray]: polygons for this mask.
            Each ndarray has format [x, y, x, y, ...]
        mask (np.ndarray): a binary mask
    """
    def __init__(self, mask: np.ndarray, height: int, width: int):
        self._mask = self._polygons = self._has_holes = None
        self.height = height
        self.width = width

        if isinstance(mask, np.ndarray):  # assumed to be a binary mask
            assert mask.shape[1] != 2, mask.shape
            assert mask.shape == (
                height,
                width,
            ), f"mask shape: {mask.shape}, target dims: {height}, {width}"
            self._mask = mask.astype("uint8")
            return

        raise ValueError("GenericMask cannot handle object {} of type '{}'".format(m, type(m)))

    @property
    def mask(self):
        if self._mask is None:
            self._mask = self.polygons_to_mask(self._polygons)
        return self._mask

    @property
    def polygons(self):
        if self._polygons is None:
            self._polygons, self._has_holes = self.mask_to_polygons(self._mask)
        return self._polygons

    @property
    def has_holes(self):
        if self._has_holes is None:
            if self._mask is not None:
                self._polygons, self._has_holes = self.mask_to_polygons(self._mask)
            else:
                self._has_holes = False  # if original format is polygon, does not have holes
        return self._has_holes

    def mask_to_polygons(self, mask):
        # cv2.RETR_CCOMP flag retrieves all the contours and arranges them to a 2-level
        # hierarchy. External contours (boundary) of the object are placed in hierarchy-1.
        # Internal contours (holes) are placed in hierarchy-2.
        # cv2.CHAIN_APPROX_NONE flag gets vertices of polygons from contours.
        mask = np.ascontiguousarray(mask)  # some versions of cv2 does not support incontiguous arr
        res = cv2.findContours(mask.astype("uint8"), cv2.RETR_CCOMP, cv2.CHAIN_APPROX_NONE)
        hierarchy = res[-1]
        if hierarchy is None:  # empty mask
            return [], False
        has_holes = (hierarchy.reshape(-1, 4)[:, 3] >= 0).sum() > 0
        res = res[-2]
        res = [x.flatten() for x in res]
        # These coordinates from OpenCV are integers in range [0, W-1 or H-1].
        # We add 0.5 to turn them into real-value coordinate space. A better solution
        # would be to first +0.5 and then dilate the returned polygon by 0.5.
        res = [x + 0.5 for x in res if len(x) >= 6]
        return res, has_holes

    def polygons_to_mask(self, polygons):
        rle = cocomask.frPyObjects(polygons, self.height, self.width)
        rle = cocomask.merge(rle)
        return cocomask.decode(rle)[:, :]

    def area(self):
        return self.mask.sum()

    def bbox(self):
        p = cocomask.frPyObjects(self.polygons, self.height, self.width)
        p = cocomask.merge(p)
        bbox = cocomask.toBbox(p)
        bbox[2] += bbox[0]
        bbox[3] += bbox[1]
        return bbox
