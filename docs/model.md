# Model

_model_ is the pipeline component used to process ingested visual data. VDP uses [Triton Inference server](https://github.com/triton-inference-server/server/releases/tag/v2.18.0) for model serving. It supports multiple deep learning frameworks including TensorFlow, PyTorch, TensorRT, ONNX and OpenVINO. Besides, the [Python Backend](https://github.com/triton-inference-server/python_backend#model-config-file) enables Triton to support any model written in Python.

## Prepare your own model to deploy on VDP
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

Triton Python Backend supports `conda-pack` to deploy Python models with dependencies. We provide a custom Conda environment that contains Numpy and Scikit-Learn. If your model is not compatible with Python 3.8 or if it requires additional dependencies, you could [create your own Conda environment](https://github.com/triton-inference-server/python_backend#2-packaging-the-conda-environment) and configure the `config.pbtext` to point to the custom conda-pack tar file accordingly.

To deploy your Vision AI model with Python code for pre-processing and post-processing:
- Convert your Python code into a pre-processing model and a post-processing model that are compatible with the Python Backend following the guideline above
- Set up an [Ensemble model](https://github.com/triton-inference-server/server/blob/main/docs/architecture.md#ensemble-models) to encapsulate a "pre-processing model -> Vision AI model -> post-processing model" procedure
- compress all model files into a `.zip` file
- use the [sample codes](../examples-go/deploy-model/main.go) to deploy the model

## Standardise output format of the model inference
To get the model inference output in a standarised format, you can specify a Computer Vision (CV) task when creating a model in VDP. The model output has to conform to the required format of that task so it can be parsed correctly. If no CV task is specified when creating a model, the inference output will be in Triton raw message ModelInferResponse format.

### Supported CV tasks
Here is a list of CV tasks that VDP supports.
- CLASSIFICATION
- DETECTION

We will continue adding new CV tasks and make the parser more flexible. If you want to make a request, please feel free to open an issue and describe your use case in details.

#### CLASSIFICATION
__Required model output format__

A string with format:
```
{label name}:{label category}:{score}  # example: 'dog:16:0.998824'
```

__Standardised output example__
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

#### DETECTION
__Required model output format__

Two arrays for Label and Box object:

Label array:
```
labels: [[label], label]]
```
Box object array:
```
bboxes: [[Left, Top, Width, Height, Score], [Left, Top, Width, Height, Score]]
```

__Standardised output example__
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
