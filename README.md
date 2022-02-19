<h1 align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/vdp.png" alt="Instill AI - Visual Data Preparation Made for All" />
</h1>

<h4 align="center">
    <a href="https://www.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Website</a> |
    <a href="https://discord.gg/sevxWsqpGh">Community</a> |
    <a href="https://blog.instill.tech/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme">Blog</a>
</h4>

<h4 align="center">
    <p>
        <a href="https://www.instill.tech/get-access/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme"><strong>Get Early Access</strong></a>
    <p>
</h4>

---

**Visual Data Preparation (VDP)** is an open-source tool to streamline the end-to-end visual data processing pipeline:

1. Ingest unstructured visual data from data sources such as data lakes or IoT devices;
2. Transform visual data to meaningful structured data representations by Vision AI models;
3. Load the structured data into warehouses, applications or other destinations.

The goal of VDP is to seamlessly bring Vision AI into modern data stack with a standardised framework. Check our blog post [Missing piece in modern data stack: visual data preparation](https://blog.instill.tech/visual-data-preparation/?utm_source=github&utm_medium=banner&utm_campaign=vdp_readme) on how this tool is proposed to streamline unstructured visual data processing across different stakeholders.

### Table of contents <!-- omit in toc -->
- [How VDP works](#how-vdp-works)
  - [SYNC](#sync)
  - [ASYNC](#async)
- [Quick start](#quick-start)
  - [Download and run VDP locally](#download-and-run-vdp-locally)
  - [Run the samples to trigger an object detection pipeline](#run-the-samples-to-trigger-an-object-detection-pipeline)
  - [Create a pipeline with your own model](#create-a-pipeline-with-your-own-model)
- [Community support](#community-support)
- [Documentation](#documentation)
  - [API reference](#api-reference)
  - [Build docker](#build-docker)
- [License](#license)

## How VDP works

The core concept of VDP is _pipeline_. A pipeline is an end-to-end workflow that automates end-to-end visual data processing. Each pipeline consists of three ordered components:
1. **data source**: where the pipeline starts. It connects the source of image and video data to be processed and has a trigger mechanism for initiating the pipeline execution.
2. **model**: a deployed Vision AI model to process the ingested visual data and generate structured outputs
3. **data destination**: where to send the structured outputs

Based on the trigger mechanism of the data source, when you trigger a pipeline, it will ingest and process the visual data, send the outputs to the destination every time the trigger event occurs.

We use **data connector** as a general term to represent data source and data destination. A list of current supported data connectors can be found [here](docs/connectors/).

We will continue adding new connectors to VDP. If you want to make a request, please feel free to open an issue and describe your use case in details.

## Quick start

### Download and run VDP locally

Execute the following commands to start pre-built images with all the dependencies

```bash
git clone https://github.com/instill-ai/vdp.git

mkdir conda-pack
curl -o conda-pack/python-3-8.tar.gz https://artifacts.instill.tech/vdp/conda-pack/python-3-8.tar.gz

make all
```

### Run the samples to trigger an object detection pipeline
We provide sample codes on how to build and trigger an object detection pipeline. Run it with the local VDP.

```bash
cd examples-go

# Download a YOLOv4 ONNX model for object detection task (GPU not required)
curl -o yolov4-onnx-cpu.zip https://artifacts.instill.tech/vdp/sample-models/yolov4-onnx-cpu.zip

# [optional] Download a test image or use your own images
curl -o dog.jpg https://artifacts.instill.tech/dog.jpg

# Deploy the model
go run deploy-model/main.go --model-path yolov4-onnx-cpu.zip --model-name yolov4

# Test the model
go run test-model/main.go --model-name yolov4 --model-version 1 --test-image dog.jpg

# Create an object detection pipeline
go run create-pipeline/main.go --pipeline-name hello-pipeline --model-name yolov4

# Trigger the pipeline by using the same test image
go run trigger-pipeline/main.go --pipeline-name hello-pipeline --test-image dog.jpg
```

### Create a pipeline with your own model
#### Prepare your own model to run on Triton Inference server
VDP uses [Triton Inference server](https://github.com/triton-inference-server/server/releases/tag/v2.18.0) for model serving. It supports multiple deep learning frameworks including TensorFlow, PyTorch, TensorRT, ONNX and OpenVINO. Besides, the [Python Backend](https://github.com/triton-inference-server/python_backend#model-config-file) enables Triton to support any model written in Python.
To deploy a model on VDP, it needs to be prepared following the layout below (refer to [Triton documentation](https://github.com/triton-inference-server/server/blob/main/docs/model_repository.md))
```
<model-name>/
  [config.pbtxt]
  [<output-labels-file> ...]
  <version>/
    <model-definition-file>
  <version>/
    <model-definition-file>
```
The config.pbtxt file describes the [model configuration](https://github.com/triton-inference-server/server/blob/main/docs/model_configuration.md) for the model.
To prepare pre-processing and post-processing model in Python Backend, create a Python file with a [structure](https://github.com/triton-inference-server/python_backend#usage) similar to below:
```
import triton_python_backend_utils as pb_utils
class TritonPythonModel:
    """Your Python model must use the same class name. Every Python model
    that is created must have "TritonPythonModel" as the class name.
    """

    def initialize(self, args):
        """`initialize` is called only once when the model is being loaded.
        Implementing `initialize` function is optional. This function allows
        the model to initialize any state associated with this model.

        Parameters
        ----------
        args : dict
          Both keys and values are strings. The dictionary keys and values are:
          * model_config: A JSON string containing the model configuration
          * model_instance_kind: A string containing model instance kind
          * model_instance_device_id: A string containing model instance device ID
          * model_repository: Model repository path
          * model_version: Model version
          * model_name: Model name
        """
        print('Initialized...')

    def execute(self, requests):
        """`execute` must be implemented in every Python model. `execute`
        function receives a list of pb_utils.InferenceRequest as the only
        argument. This function is called when an inference is requested
        for this model.

        Parameters
        ----------
        requests : list
          A list of pb_utils.InferenceRequest

        Returns
        -------
        list
          A list of pb_utils.InferenceResponse. The length of this list must
          be the same as `requests`
        """

        responses = []

        # Every Python backend must iterate through list of requests and create
        # an instance of pb_utils.InferenceResponse class for each of them. You
        # should avoid storing any of the input Tensors in the class attributes
        # as they will be overridden in subsequent inference requests. You can
        # make a copy of the underlying NumPy array and store it if it is
        # required.
        for request in requests:
            # Perform inference on the request and append it to responses list...

        # You must return a list of pb_utils.InferenceResponse. Length
        # of this list must match the length of `requests` list.
        return responses

    def finalize(self):
        """`finalize` is called only once when the model is being unloaded.
        Implementing `finalize` function is optional. This function allows
        the model to perform any necessary clean ups before exit.
        """
        print('Cleaning up...')
```          
Triton Python Backend supports `conda-pack` to deploy Python models with dependencies. We provide a custom Conda environment that contains Numpy and Scikit-Learn. If your model is not compatible with Python 3.8 or if it requires additional dependencies, you could [create your own Conda environment](https://github.com/triton-inference-server/python_backend#2-packaging-the-conda-environment).
To deploy your DL model with Python code for pre-processing and post-processing and used in a pipeline: 
- Convert your Python code into a pre-processing model and a post-processing model that are compatible with the Python Backend following the guideline above
- Set up an [Ensemble model](https://github.com/triton-inference-server/server/blob/main/docs/architecture.md#ensemble-models) to encapsulate a "pre-processing model -> DL model -> post-processing model" procedure.
- compress all model files into a `.zip` file
- use the sample codes above to deploy the model and create you pipeline
#### Model standardization format output
To standardise the output format of the model inference, you can specify the targeted Computer Vision (CV) task when creating a model in VDP. Here is a list of CV tasks that VDP supports.
- `CLASSIFICATION`
- `DETECTION`

For the `CLASSIFICATION` task, here is an output example:
```
{
    "contents": [
        {
            "contents": [
                {
                    "category": "dog",
                    "score": 0.980409,
                    "box": {
                        "top": 99.084984,
                        "left": 325.79257,
                        "width": 204.18991,
                        "height": 402.58002
                    }
                }
            ]
        }
    ]
}
```
For the `DETECTION` task, here is an output example
```
{
    "contents": [
        {
            "category": "dog",
            "score": 0.998824
        }
    ]
}
```
Note: 

To output with a standardised format, the post-processing PyThon model for the `CLASSIFICATION` task should output string withh format:
```
{label name}:{label category}:{score}  # example: 'dog:16:0.998824'
```

To output with a standardised format, the post-processing PyThon model for the `DETECTION` task should output two arrays for Label and Box object:

Label array:
```
labels: [[label], label]]
```
Box object array:
```
bboxes: [[Left, Top, Width, Height, Score], [Left, Top, Width, Height, Score]]
```
If no CV task is specified when creating a model in VDP, the inference output will be in Triton raw message ModelInferResponse format.

## Community support

For general help using VDP, you can use one of these channels:

- [GitHub](https://github.com/instill-ai/vdp) (bug reports, feature requests, project discussions and contributions)
- [Discord](https://discord.gg/sevxWsqpGh) (live discussion with the community and the Instill AI Team)

## Documentation

### API reference

### Build docker

You can build a development Docker image using:
```bash
make build
```

## License

See the [LICENSE](https://github.com/instill-ai/vdp/blob/main/LICENSE) file for licensing information.
