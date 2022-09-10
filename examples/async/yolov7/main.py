import os
import sys
import typing
import pathlib
import argparse
import time
import shutil
from os import listdir
from os.path import isfile, join
from typing import Final, Any, List, Dict

import cv2
import ffmpeg
import psycopg2
import requests
import numpy as np
from tqdm import tqdm
from tqdm.contrib import tzip
from google.cloud import storage

from utils import draw_detection


def download_data(filename):

    print("\n===== Download video from GCS bucket...")

    client = storage.Client.create_anonymous_client()
    bucket = client.bucket('public-europe-west2-c-artifacts')
    blob = bucket.blob("vdp/tutorial/cows_dornick/cows_dornick.mp4")
    blob.download_to_filename(filename)
    print("Done!")

def extract_frames_from_video(image_dir, filename, framerate=30):
    if os.path.exists(image_dir) and os.path.isdir(image_dir):
        shutil.rmtree(image_dir)

    print("\n===== Extract frames from the video {} into {} ...".format(filename, image_dir))
    
    pathlib.Path(image_dir).mkdir(parents=True, exist_ok=True)
    try:
        (
            ffmpeg.input(filename)
                .filter('fps', fps=framerate)
                .output(join(image_dir, 'frame%5d.png'),
                        start_number=0)
                .run(capture_stdout=True, capture_stderr=True)
        )
        print("Done!\n")
    except ffmpeg.Error as error:
        print('stdout:', error.stdout.decode('utf8'))
        print('stderr:', error.stderr.decode('utf8'))


def generate_video_from_frames(image_dir, output_filename, framerate=30):
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
    except ffmpeg.Error as error:
        print(error)


def parse_detection_from_database(detection_ls: List[Dict[str, Any]]):
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

###############################################################################
# VDP backends
###############################################################################

# TODO: replace with future api-gateway
ver: Final[str] = "v1alpha"
backend: typing.Dict[str, str] = {
    "pipeline": "localhost:8081",
    "connector": "localhost:8082",
    "model": "localhost:8083",
}

###############################################################################
# PostgreSQL
###############################################################################

# Create PostgreSQL database
pq_cfg: typing.Dict[str, Any] = {
    "host": "100.113.68.102",
    "port": 5432,
    "database": "tutorial",
    "schema": "public",
    "username": "postgres",
    "password": "password",
    "ssl": False
}

if __name__ ==  '__main__':
    parser = argparse.ArgumentParser(description='Trigger VDP pipeline')
    parser.add_argument("--pipeline", dest = 'pipeline', help = 
                        "VDP pipeline ID",
                        default = "detection", type = str)
    parser.add_argument("--output-filename", dest = 'output_filename', help = 
                        "Output video file name", 
                        default = "output.mp4", type = str)
    parser.add_argument("--framerate", dest = 'framerate', help = 
                        "Frame rate of the video", 
                        default = 30, type = int)
    parser.add_argument("--skip-draw", dest="draw", action="store_false", help = 
                        "Skip draw detections on images")
    
    opt = parser.parse_args()

    ###############################################################################
    # Download video and extract frames
    ###############################################################################

    video_filename = join(os.path.dirname(os.path.realpath(__file__)), "cows_dornick.mp4")

    skip_download = os.path.exists(video_filename)
    if skip_download:
        print("\n===== Skip downloading video")
    else:
        download_data(video_filename)

    ###############################################################################
    # Extract frames from the video file
    ###############################################################################
    
    image_dir = join(os.path.dirname(os.path.realpath(__file__)), "inputs")

    skip_extract = False
    if os.path.exists(image_dir) and os.path.isdir(image_dir):
        if os.listdir(image_dir):
            skip_extract = True
    if skip_extract:
        print("\n===== Skip extracting frames from video {}".format(video_filename))
    else:
        extract_frames_from_video(image_dir, video_filename, framerate=opt.framerate)

    ###############################################################################
    # Trigger pipeline to process video frames
    ###############################################################################

    batch_size = 1
    img_files = [filename for filename in sorted(listdir(image_dir)) if isfile(
        join(image_dir, filename)) and not filename.startswith(".")]    
    img_batch = [img_files[i:i+batch_size]  for i in range(0, len(img_files), batch_size)]
    filenames = [file for files in img_batch for file in files]
    data_mapping_indices = []

    print("\n=====Trigger {} pipeline to process images in '{}'\n".format(opt.pipeline, image_dir))    
    for files in tqdm(img_batch):
        resp = requests.post(f'http://{backend["pipeline"]}/{ver}/pipelines/{opt.pipeline}:trigger-multipart',
                        files=[("file", (filename, open(join(image_dir, filename), 'rb'))) for filename in files])
        if resp.status_code == 200:
            data_mapping_indices += resp.json()['data_mapping_indices']
        else:
            print(resp.status_code)
            print(resp.json())
            sys.exit()

    ###############################################################################
    # Draw detections on video frames
    ###############################################################################

    if opt.draw:
        time.sleep(10)
        conn = None
        print("#", end="", flush=True)
        assert len(filenames) == len(data_mapping_indices), "number of files {} not consistent with number of records {}".format(len(filenames), len(data_mapping_indices))
        
        # Create output directory
        output_dir = join(os.path.dirname(os.path.realpath(__file__)), "outputs")
        pathlib.Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        for filename, mapping_index in tzip(filenames, data_mapping_indices):
            # Fetch detections from destination PostgreSQL database
            try:
                conn = psycopg2.connect(
                    user=pq_cfg["username"], password=pq_cfg["password"], host=pq_cfg["host"], port=pq_cfg["port"], database=pq_cfg["database"])
                cur = conn.cursor()
                cur.execute("""SELECT _airbyte_raw_detection._airbyte_data->'detection'->'bounding_boxes' AS "bounding_boxes" from _airbyte_raw_detection WHERE _airbyte_raw_detection._airbyte_data->>'index' = '{}'""".format(mapping_index))
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

        if conn is not None:
            conn.close()

        # Generate video with detections
        generate_video_from_frames(output_dir, opt.output_filename, framerate=opt.framerate)