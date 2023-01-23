import os
import sys
import typing
import pathlib
import argparse
import shutil
from os import listdir, path
from os.path import isfile, join
from typing import Final, Any, List, Dict, Tuple

import ffmpeg
import requests
import numpy as np
from tqdm import tqdm
from tqdm.contrib import tzip
from google.cloud import storage

from utils import draw_detection


############################################################################
# Helper Functions
############################################################################

def download_data(bucket_name: str, blob_filename: str, dst_filename: str) -> bool:
    r""" Download a file from a GCS bucket into a local file

    Args:
        bucket_name (str): GCS bucket name
        blob_filename (str): file name to be downloaded from the in the GCS bucket
        dst_filename (str): the file name used to save the downloaded file

    Returns: bool
        a flag to indicate whether the downloading is successful

    """
    print("\n===== Download video {} from GCS bucket {} to {} ...".format(blob_filename, bucket_name, dst_filename))

    client = storage.Client.create_anonymous_client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_filename)
    try:
        blob.download_to_filename(dst_filename)
    except Exception as e:
        print(e)
        os.remove(dst_filename)
        return False
    print("Done!")
    return True

def extract_frames_from_video(image_dir: str, filename: str, framerate: int=30) -> bool:
    r""" Extract frames from a video file at constant frames per second

    Args:
        image_dir (str): the directory where the extracted frames will be stored
        filename (str): name of the video file
        framerate (int): frames per second (fps) to extract the video. By default set to 30 fps.

    Returns: bool
        a flag to indicate whether the extraction is successful

    """
    print(join(image_dir, 'frame.png'))
    if os.path.exists(image_dir) and os.path.isdir(image_dir):
        shutil.rmtree(image_dir)

    print("\n===== Extract frames from the video {} into {} ...".format(filename, image_dir))

    pathlib.Path(image_dir).mkdir(parents=True, exist_ok=True)
    print('File location: ' + filename)
    print("If file exist: " + str(path.isfile(filename)))
    try:
        (
            ffmpeg.input(filename)
                .filter('fps', fps=framerate)
                .output(join(image_dir, 'frame%5d.png'),
                        start_number=0)
                .run(capture_stdout=True, capture_stderr=True)
        )
        print("Done!\n")
        return True
    except ffmpeg.Error as error:
        print('EEEEEEEERRRRRRR')
        print('stdout:', error.stdout.decode('utf8'))
        print('stderr:', error.stderr.decode('utf8'))
        shutil.rmtree(image_dir)
        return False

def trigger_pipeline_multipart(pipeline_backend_url: str, pipeline_id: str, img_folder: str, img_names: list()) -> requests.Response:
    r""" Trigger a pipeline composed with a detection model instance using remote image URL

    Args:
        pipeline_backend_url (str): VDP pipeline backend base URL
        pipeline_id (str): pipeline ID
        img_names List(str): local image path

    Returns: requests.Response
        pipeline trigger result

    """

    body = [("file", (img_name, open(os.path.join(img_folder, img_name), 'rb'))) for img_name in img_names]

    return requests.post(
        f"{pipeline_backend_url}/pipelines/{pipeline_id}/trigger-multipart", 
        files=body)

############################################################################
# Settings: VDP backends
############################################################################

# TODO: replace with future api-gateway
ver: Final[str] = "v1alpha"
backend: typing.Dict[str, str] = {
    "pipeline": "localhost:8081",
    "connector": "localhost:8082",
    "model": "localhost:8083",
}

if __name__ ==  '__main__':
    parser = argparse.ArgumentParser(description='Trigger VDP pipeline')
    parser.add_argument("--pipeline", dest = 'pipeline', help = "VDP pipeline ID",
                        default = "vdp-101-async", type = str)
    parser.add_argument("--framerate", dest = 'framerate', help = "Frame rate of the video",
                        default = 30, type = int)
    parser.add_argument("--batch-size", dest = 'batch_size', help = "Batch size of the multipart payload.",
                        default = 2, type = int)
    parser.add_argument("--mapping-file", dest = 'mapping_file', help = "File stores the mapping indices for pipeline triggers.",
                        default = "data-mapping-indices.txt", type = str)
    parser.add_argument("--backend", dest = 'backend', help = "File stores the mapping indices for pipeline triggers.",
                        default = backend['pipeline'], type = str)

    opt = parser.parse_args()
    backend['pipeline'] = opt.backend

    ########################################################################
    # Download video
    ########################################################################

    video_filename = join(os.path.dirname(os.path.realpath(__file__)), "ctriggers")

    skip_download = os.path.exists(video_filename)
    if skip_download:
        print("\n===== Skip downloading video")
    else:
        success = download_data(bucket_name='public-europe-west2-c-artifacts',
        blob_filename="vdp/tutorial/cows_dornick/cows_dornick.mp4",
        dst_filename=video_filename)
        if not success:
            print("Video download was unsuccess.")
            sys.exit(1)

    ########################################################################
    # Extract frames from the video file
    ########################################################################

    image_dir = join(os.path.dirname(os.path.realpath(__file__)), "inputs")

    skip_extract = False
    if os.path.exists(image_dir) and os.path.isdir(image_dir):
        if os.listdir(image_dir):
            skip_extract = True
    if skip_extract:
        print("\n===== Skip extracting frames from video {}".format(video_filename))
    else:
        success = extract_frames_from_video(image_dir, video_filename, framerate=opt.framerate)
        if not success:
            print("Frame extraction was unsuccessful.")
            sys.exit(1)


    ########################################################################
    # Trigger pipeline to process video frames
    ########################################################################

    ## prepare image list.
    batch_size = opt.batch_size
    img_files = [filename for filename in sorted(listdir(image_dir)) if isfile(
        join(image_dir, filename)) and not filename.startswith(".")]
    img_batch = [img_files[i:i+batch_size]  for i in range(0, len(img_files), batch_size)]
    filenames = [file for files in img_batch for file in files]

    ## set write path
    output_file = join(os.path.dirname(os.path.realpath(__file__)), opt.mapping_file)

    ## clear previous index record stored in the file.
    with open(output_file, "w") as f:
        f.close()

    print(f"\n===== Trigger {opt.pipeline} pipeline to process images in '{image_dir}'\n")

    for files in tqdm(img_batch, position=0, leave=True):
        pipeline_backend_url = f'http://{backend["pipeline"]}/{ver}'
        resp = trigger_pipeline_multipart(pipeline_backend_url, opt.pipeline,image_dir,files)
        
        if resp.status_code == 200:
            mapping_indices = resp.json()['data_mapping_indices']
            with open(output_file, "a") as f:
                for index in mapping_indices:
                    f.write(index+'\n')
        else:
            sys.exit(1)

    print("\n===== All images are uploaded successfully!")