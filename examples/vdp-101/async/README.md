# VDP 101 ASYNC Pipeline Example - Object detection

This example supports [VDP 101 [7/7] Create, Trigger, and Parse an ASYNC Pipeline](https://www.instill.tech/tutorials/vdp-101-7-create-trigger-parse-a-async-pipeline).

## 1. Prerequisites
In this tutorial, we'll use the same development environment below as in our previous tutorials. 
- VDP
- Docker and Docker Compose
- Conda Environment
- Install required dependencies with

```bash
# move to the example directory for the VDP-101 ASYNC tutorial.
cd /example/vdp-101/async
# install dependencies.
pip install -r requirement.txt
```

You can manage these dependencies with a Conda environment. For further information,  we refer users to [anaconda](https://docs.anaconda.com/anaconda/install/silent-mode/) or [miniconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html#installing-conda-on-a-system-that-has-other-python-installations-or-packages).

## How to run this demo
This example consists of two Python scripts. `tigger.py` triggers the pipeline to process the object-detection task with the images extracted from a video. `process.py` downloads the task results from a Postgres database and outputs a video with labelled objects.

- `tigger.py` downloads an example video, which is then converted into images (with OpenCV) for an **object detection** task using **YOLOv7**. It triggers the `ASYNC` pipeline using HTTP multipart requests.
- `process.py` requests the `ASYNC` pipeline outputs (i.e., object detection results with YOLOv7) from local Postgres DB. It then processes these outputs with local images to reconstruct a video with object detection results.


## Trigger the ASYNC pipeline with `trigger.py`
Now would like to trigger the `ASYNC` pipeline we just created by running the script below.

```bash
# tigger the ASYNC pipeline we just created
python trigger.py
```

This script first downloads a video `cows_dornick.mp4` to the `async` folder, extracts frames from the video file, and saves these frames to the `async/input` folder. Once the extraction is complete, the script triggers the pipeline with image batches using *HTTP Multipart POST Requests*. 

The pipeline responds with the **indices** (corresponding to each image), which are ultimately saved to an output file `data-mapping-indices.txt` under the `async` fold by default.

Unlike the responses in the `SYNC` mode, the `ASYNC` pipeline only responds with `data_mapping_indices` for each uploaded data.

```python
## This is the object returned in ASYNC and PULL modes.
{  
	"data_mapping_indices": [  
		"01GDR4ZW7W4T2H2G8MK79Y49PG",  
		"01GDR4ZW7W4T2H2G8MK8AR1T2B"  
	],  
	"model_instance_outputs": []  
}

```

After All the images are uploaded to the pipeline, you can check the indices using the command below:

```bash
# preview the request index file.
cat data-mapping-indices.txt
```

### Optional command-line arguments

The script `trigger.py` provides command-line arguments below.

- `--pipeline`: Pipeline ID on VDP. Default `vdp-101-async`.
- `--framerate`: Frame rate of the video. Default `30`.
- `--batch-size`: Batch size of the multipart payload. Default `2`.
- `--mapping-file`: File stores the mapping indices for pipeline triggers. Default `data-mapping-indices.txt`.
- `--backend`: The IP and port of the backend pipeline service. Default `localhost:8081`.

You can find further details of these arguments in `README.md` under the `async` folder.

> **NOTE**  
> VDP limits the maximum image size to 12MB by default. 

## Retrieve and output inference results from Database `process.py`

After the `vdp-101-async` pipeline has processed all the uploaded images for the object detection task, we can download the inference result from the database with the `data-mapping-indices` we saved locally. Run the script below to download and visualise the result of the pipeline outputs.

```bash
# download and visualise the results from the database.
python process.py
```

This script exploits the indices stored in the `data-mapping-indices.txt` to locate the corresponding object detection results for each frame stored in `async/output`.

WHALA! Once everything is processed, you should find the output video `output.mp4` under the `async/outputs` folder.


### Optional command-line arguments

The script `process.py` provides command-line arguments below. Users can also change these settings in the `process.py`. 

- `--host`: IP address of the Postgres host. Default `localhost`. 
- `--port`: Postgres service port. Default `5432`.
- `--database`: Name of the database. Default `tutorial`.
- `--username`: Login username. Default `postgres`.
- `--password`: Login password. Default `password`.
- `--output`: Output video file name. Default `output.mp4`.
- `--framerate`: Frame rate of the video. Default `30`.

> **NOTE**  
> When setting `--host`, users may need to indicate with **actual** IP address instead of **localhost** to access the Postgres database running in a docker container.
