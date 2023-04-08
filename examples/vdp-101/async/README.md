# VDP 101 ASYNC Pipeline Example - Object detection

This example supports [VDP 101 [7/7] Create, trigger, and parse an ASYNC pipeline](https://www.instill.tech/tutorials/vdp-101-7-create-trigger-parse-an-async-pipeline).

## Prerequisites
Please follow the [VDP 101 [7/7] Create, trigger, and parse an ASYNC pipeline](https://www.instill.tech/tutorials/vdp-101-7-create-trigger-parse-an-async-pipeline) to build the ASYNC Object Detection pipeline `vdp-101-async` before running the examples.

## How to run the examples
This example consists of two Python scripts:
- `trigger.py` downloads an example video, which is then converted into images (with OpenCV) for an **object detection** task using **YOLOv7**. It triggers the `ASYNC` pipeline using HTTP multipart requests.
- `process.py` requests the `ASYNC` pipeline outputs (i.e., object detection results with YOLOv7) from local Postgres DB. It then processes these outputs with local images to reconstruct a video with object detection results.


### Trigger the ASYNC pipeline with `trigger.py`
Now would like to trigger the `ASYNC` pipeline we just created by running the script below.

```bash
# Trigger the ASYNC pipeline we just created
#   --api-gateway-url=< VDP API base URL >
#   --pipeline-id=< Pipeline ID indicates the pipeline to trigger>
#	--framerate=< Frame rate of the video file, default is 30 >
#	--mapping-file=< File that stores the mapping indices for each processed image, default is 'data-mapping-indices.txt' >
$ python trigger.py --api-gateway-url=http://localhost:8080 --pipeline-id=vdp-101-async --framerate=30 --mapping-file=data-mapping-indices.txt
```

This script first downloads a video `cows_dornick.mp4` to this folder, extracts frames from the video file, and saves these frames to the `inputs` folder. Once the extraction is complete, the script triggers the pipeline to process all frames using *HTTP Multipart POST Requests*. 

The pipeline responds with the **indices** (corresponding to each image), which are ultimately saved to an output file `data-mapping-indices.txt` by default.

Unlike the responses in the `SYNC` mode, the `ASYNC` pipeline responds with `data_mapping_indices` that records the trigger operation ID for each image to be processed.

```json
## Here is a response example returned by triggering an ASYNC pipeline.
{  
	"data_mapping_indices": [  
		"01GDR4ZW7W4T2H2G8MK79Y49PG"
	],  
	"model_outputs": []  
}

```

After All the images are processed by the pipeline, you can check the indices using the command below:

```bash
# Preview the request index file
cat data-mapping-indices.txt
```

### Retrieve and visualise inference results from Database with `process.py`

After the `vdp-101-async` pipeline has processed all the images for the object detection task, we can fetch all the corresponding inference result from the database by mapping with the trigger operation IDs in the `data-mapping-indices.txt`. Run the script below to fetch the pipeline detection outputs from the database, visualise the fetched detections on the corresponding input image and save to the `outputs` folder.

```bash
# Fetch and visualise the results from the database
#   --pq-host=< database host >
#   --pq-port=< database port >
#   --pq-database=< database name >
#   --pq-username=< database username >
#   --pq-password=< database password >
#   --output-filename=< output image directory, default is set to 'output.mp4' >
#   --framerate=< frame rate of the video file, default is set to 30 >
$ python process.py --pq-host=< database host > --pq-port=< database port > --pq-database=tutorial --pq-username=< database username > --pq-password=< database password > --output-filename=output.mp4 --framerate=30
```

WHALA! Once everything is processed, you should find a video file `output.mp4` created from images in the `outputs` folder with all the images drawn with detected results.


> **NOTE**  
> When setting `--pq-host`, users may need to indicate with **actual** IP address instead of **localhost** to access the Postgres database from a docker container.
