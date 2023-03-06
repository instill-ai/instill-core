import os
import typing
import pathlib
import argparse
import cv2
import ffmpeg
import psycopg2
import numpy as np
from os import listdir
from os.path import isfile, join
from typing import Final, Any, List, Dict, Tuple
from tqdm.contrib import tzip

from utils import draw_detection


############################################################################
# Helper Functions
############################################################################

def generate_video_from_frames(image_dir: str, output_filename: str, framerate: int=30) -> bool:
    r""" Generate a video from a array of image frames

    Args:
        image_dir (str): the directory where the image frames are stored
        output_filename (str): the name of the video file to be generated
        framerate (int): fps of the video to be generated

    Returns: bool
        a flag to indicate whether the operation is successful

    """
    if os.path.exists(output_filename):
        os.remove(output_filename)

    print("\n=====Generate video {} from image files in {}...".format(output_filename, image_dir))
    try:
        (
            ffmpeg
                .input(join(image_dir, '*.png'), pattern_type='glob', framerate=framerate)
                .output(output_filename, pix_fmt="yuv420p")
                .run()
        )
        print("Done!\n")
        return True
    except ffmpeg.Error as error:
        print(error)
        return False


def parse_detection_from_database(detection_ls: List[Dict[str, Any]]) -> Tuple[List[Tuple[float]], List[str], List[float]]:
    r""" Parse the raw detection output from the database

    Args:
        detection_ls: a list of detection outputs for standardised VDP object detection task
        [
            {
                "bounding_box": {
                    "left": 324,
                    "top": 102,
                    "width": 208,
                    "height": 405,
                },
                "category": "dog",
                "score": 0.9
            }
        ]

    Returns: parsed output, a tuple of
        List[Tuple[float]]: a list of detected bounding boxes in the format of (left, top, width, height)
        List[str]: a list of category labels, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.
        List[float]: a list of scores, each of which corresponds to a detected bounding box. The length of this list must be the same as the detected bounding boxes.

    """
    boxes_ltwh, categories, scores = [], [], []

    for det in detection_ls:
        boxes_ltwh.append((
            det["bounding_box"]["left"],
            det["bounding_box"]["top"],
            det["bounding_box"]["width"],
            det["bounding_box"]["height"]))
        categories.append(det["category"])
        scores.append(det["score"])

    return boxes_ltwh, categories, scores

if __name__ ==  '__main__':
    parser = argparse.ArgumentParser(description='Download data from Postgres DB')
    parser.add_argument("--pq-host", dest="pq_host", help = "PostgreSQL database host", type=str)
    parser.add_argument("--pq-port", dest="pq_port", help =
                        "PostgreSQL database port", default = 5432, type=int)
    parser.add_argument("--pq-database", dest="pq_database", help =
                        "PostgreSQL database name", default = "tutorial", type=str)
    parser.add_argument("--pq-username", dest="pq_username", help =
                        "PostgreSQL database username", default = "postgres", type=str)
    parser.add_argument("--pq-password", dest="pq_password", help =
                        "PostgreSQL database password", default = "password", type=str)
    parser.add_argument("--output-filename", dest = 'output_filename', help = "Output video file name",
                        default = "output.mp4", type = str)
    parser.add_argument("--framerate", dest = 'framerate', help = "Frame rate of the video",
                        default = 30, type = int)

    opt = parser.parse_args()

    #########################################################################
    # Draw detections on video frames
    #########################################################################

    print("\n===== Start extracting results from postgres-db")
    image_dir = join(os.path.dirname(os.path.realpath(__file__)), "inputs")
    filenames = [filename for filename in sorted(listdir(image_dir)) if isfile(
        join(image_dir, filename)) and not filename.startswith(".")]

    ## write path
    output_file = join(os.path.dirname(os.path.realpath(__file__)), "data-mapping-indices.txt")

    with open(output_file, "r") as f:
        data_mapping_indices = f.readlines()
        for i in range(len(data_mapping_indices)):
            data_mapping_indices[i] = data_mapping_indices[i].strip()
        conn = None

        print("#", end="", flush=True)
        assert len(filenames) == len(data_mapping_indices), "number of files {} not consistent with number of records {}".format(len(filenames), len(data_mapping_indices))

        # Create output directory
        output_dir = join(os.path.dirname(os.path.realpath(__file__)), "outputs")
        pathlib.Path(output_dir).mkdir(parents=True, exist_ok=True)
        result_fetch_success = True
        for filename, mapping_index in tzip(filenames, data_mapping_indices):
            # Fetch detections from destination PostgreSQL database
            try:
                conn = psycopg2.connect(
                    user=opt.pq_username, password=opt.pq_password, host=opt.pq_host, port=opt.pq_port, database=opt.pq_database)
                cur = conn.cursor()
                cur.execute("""SELECT _airbyte_raw_vdp._airbyte_data->'detection'->'objects' AS "objects" from _airbyte_raw_vdp WHERE _airbyte_raw_vdp._airbyte_data->>'index' = '{}'""".format(mapping_index))
                row = cur.fetchone()[0]

                boxes_ltwh, categories, scores = parse_detection_from_database(row)
                buffer = open(join(image_dir, filename), 'rb')
                arr = np.asarray(bytearray(buffer.read()), dtype=np.uint8)
                img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
                img_draw = draw_detection(img, boxes_ltwh, categories, scores)
                cv2.imwrite(join(os.path.dirname(os.path.realpath(__file__)), output_dir, filename), img_draw)
                cur.close()

            except (Exception, psycopg2.DatabaseError) as error:
                print(error)
                result_fetch_success = False
                break

        if conn is not None:
            conn.close()

        # Generate video with detections
        if result_fetch_success:
            success = generate_video_from_frames(output_dir, opt.output_filename, framerate=opt.framerate)
            print(f'Video {opt.output_filename} was successly generated and saved to {output_dir}.')
        else:
            print('Cannot generate video due to unexpected errors. Please check hte error message above.')