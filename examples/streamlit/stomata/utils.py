import cv2
import random
import numpy as np
from skimage import measure

random.seed(0)


def random_color():
    r""" Get random color
    """
    return [random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)]

def draw_bboxes(img, boxes, texts, thickness=1, color=None):
    img_draw = img.copy()
    tl = thickness
    tf = max(tl-1, 1)
    if texts is None:
        texts = [None for _ in boxes]
    for box, text in zip(boxes, texts):
        c = random_color() if color is None else color
        x, y, w, h = box
        cv2.rectangle(img_draw, pt1=(x, y), pt2=(x+w, y+h), color=color, thickness=thickness, lineType=cv2.LINE_AA)

        t_size = cv2.getTextSize(text, 0, fontScale=tl/3, thickness=thickness)[0]
        pt = np.amin(box, axis=0)
        c1 = (x, y)
        c2 = c1[0] + t_size[0], c1[1] - t_size[1] -3
        cv2.rectangle(img_draw, c1, c2, color=color, thickness=-1, lineType=cv2.LINE_AA)  # filled
        if text is not None:
            cv2.putText(img_draw, text, (c1[0], c1[1]-2), 0, tl/3, [255,255,255], thickness=tf, lineType=cv2.LINE_AA)
    return img_draw

def draw_polygons(img, polygons, texts=None, thickness=1, color=None, draw_bounding_box=False):
    img_draw = img.copy()
    tl = thickness
    tf = max(tl-1, 1)
    if texts is None:
        texts = [None for _ in polygons]
    for p, text in zip(polygons, texts):
        color = random_color() if color is None else color
        pts_x = p[::2]
        pts_y = p[1::2]
        pts = [[x, y] for x,y in zip(pts_x, pts_y)]
        pts = np.array(pts, np.int32)
        cv2.polylines(img_draw, [pts], isClosed=True, thickness=thickness, color=color)
        # bounding box format: (tlx, tly, w, h)
        x, y, w, h = cv2.boundingRect(pts)
        if draw_bounding_box:
            cv2.rectangle(img_draw, pt1=(x, y), pt2=(x+w, y+h), color=color, thickness=thickness, lineType=cv2.LINE_AA)
        t_size = cv2.getTextSize(text, 0, fontScale=tl/3, thickness=thickness)[0]
        c1 = (x, y)
        c2 = c1[0] + t_size[0], c1[1] - t_size[1] -3
        if text is not None:
            cv2.rectangle(img_draw, c1, c2, color=color, thickness=-1, lineType=cv2.LINE_AA)  # filled
            cv2.putText(img_draw, text, (c1[0], c1[1]-2), 0, tl/3, [255,255,255], thickness=tf, lineType=cv2.LINE_AA)
    return img_draw

def draw_rotated_bboxes(img, rboxes, texts=None, thickness=1, color=None):
    img_draw = img.copy()
    tl = thickness
    tf = max(tl-1, 1)
    if texts is None:
        texts = [None for _ in rboxes]
    for rb, text in zip(rboxes, texts):
        c = random_color() if color is None else color
        box = cv2.boxPoints(rb)
        box = np.int0(box)
        cv2.drawContours(img_draw, [box], 0, color=c, thickness=thickness)
        t_size = cv2.getTextSize(text, 0, fontScale=tl/3, thickness=thickness)[0]
        pt = np.amin(box, axis=0)
        c1 = (pt[0], pt[1])
        c2 = c1[0] + t_size[0], c1[1] - t_size[1] -3
        if text is not None:
            cv2.rectangle(img_draw, c1, c2, color=color, thickness=-1, lineType=cv2.LINE_AA)  # filled
            cv2.putText(img_draw, text, (c1[0], c1[1]-2), 0, tl/3, [255,255,255], thickness=tf, lineType=cv2.LINE_AA)
    return img_draw

def rle_decode(mask_rle, mask_shape):
    r""" Decode uncompressed RLE into binary mask
    Args:
        mask_rle: run-length as string formated (start length)
        shape: (height,width) of array to return

    Returns numpy array, 1 - mask, 0 - background

    """
    if len(mask_shape) != 2:
        return None
    if not isinstance(mask_rle, str):
        return None

    s = mask_rle.split(",")
    starts, lengths = [np.asarray(x, dtype=int) for x in (s[0:][::2], s[1:][::2])]
    starts -= 1
    ends = starts + lengths
    img = np.zeros(mask_shape[0]*mask_shape[1], dtype=np.uint8)
    for lo, hi in zip(starts, ends):
        img[lo:hi] = 1
    return img.reshape(mask_shape)

def binary_mask_to_polygons(binary_mask, tolerance=0):
    r""" Converts a binary mask to COCO polygon representation
    Args:
        binary_mask: a 2D binary numpy array where '1's represent the object
        tolerance: Maximum distance from original points of polygon to approximated polygonal chain. If tolerance is 0, the original coordinate array is returned.

    """
    def close_contour(contour):
        if not np.array_equal(contour[0], contour[-1]):
            contour = np.vstack((contour, contour[0]))
        return contour

    polygons = []
    # pad mask to close contours of shapes which start and end at an edge
    padded_binary_mask = np.pad(binary_mask, pad_width=1, mode='constant', constant_values=0)
    contours = measure.find_contours(padded_binary_mask, 0.5)
    for contour in contours:
        contour = close_contour(contour)
        if len(contour) < 3:
            continue
        contour = np.flip(contour, axis=1)
        segmentation = contour.ravel().tolist()
        # after padding and subtracting 1 we may get -0.5 points in our segmentation
#         segmentation = [0 if i < 0 else i for i in segmentation]
        polygons.append(segmentation)
    return polygons


def rle_to_polygon(mask_rle, bbox_ltwh):
    r""" Convert RLE to polygons related to the original image

    Args:
        mask_rle: run-length as string formated (start length)
        bbox_ltwh: the bounding box that constraints the RLE in the format of [left, top, width, height]

    Return a list of polygons related to the original image
    """
    left, top, w, h = bbox_ltwh
    mask = rle_decode(mask_rle, (h, w))
    polygons = binary_mask_to_polygons(mask)
    o_polygons = []
    for p in polygons:
        p_copy = p.copy()
        pts_x = [x+left for x in p[::2]]
        pts_y = [y+top for y in p[1::2]]
        p_copy[::2] = pts_x
        p_copy[1::2] = pts_y
        o_polygons.append(p_copy)
    # TODO: find the outer polygon, instead of the first polygon
    return o_polygons[0]

def fit_polygens_to_rotated_bboxes(polygons):
    r""" Fit polygons to the minimum area rotated rectangle
    Args:
        polygons: a list of polygons in the format of [x1, y1, x2, y2, ...]

    Return a list of rotated bounding boxes in the format of (center(x,y), (width, height), angel of rotation)

    """
    rbboxes = []
    for p in polygons:
        pts_x = p[::2]
        pts_y = p[1::2]
        pts = [[x, y] for x,y in zip(pts_x, pts_y)]
        pts = np.array(pts, np.float32)
        rect = cv2.minAreaRect(pts)  # in the format of ((cx, cy), (w, h), a)
        rbboxes.append(rect)
    return rbboxes
