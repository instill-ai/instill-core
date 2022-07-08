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
The `config.pbtxt` file describes the [model configuration](https://github.com/triton-inference-server/server/blob/main/docs/model_configuration.md) for the model.

To deploy your Vision AI model with Python code for pre-processing and post-processing, use Triton Python Backend that supports `conda-pack` to deploy Python models with dependencies. We provide a [custom Conda environment](https://github.com/instill-ai/triton-python-model). If your model is not compatible with Python 3.8 or if it requires additional dependencies, you could [create your own Conda environment](https://github.com/triton-inference-server/python_backend#2-packaging-the-conda-environment) and configure the `config.pbtext` to point to the custom conda-pack tar file accordingly.

- Convert your Python code into a pre-processing model and a post-processing model that are compatible with the Python Backend following the guideline above
- Set up an [Ensemble model](https://github.com/triton-inference-server/server/blob/main/docs/architecture.md#ensemble-models) to encapsulate a "pre-processing model -> Vision AI model -> post-processing model" procedure
- compress all model files into a `.zip` file
- use the [sample codes](../examples-go/deploy-model/main.go) to deploy the model

### Prepare the pre-processing Python model
To prepare pre-processing model in Python Backend, create a Python file with a [structure](https://github.com/triton-inference-server/python_backend#usage) similar to below:
```python
import triton_python_backend_utils as pb_utils
class TritonPythonModel:
    """Your Python model must use the same class name. Every Python model that is created must have "TritonPythonModel" as the class name.
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

### Prepare the post-processing Python model to standardise inference output format
You can prepare the post-processing model the same way as the pre-processing model above. However, to get the model inference output in a standarised format you can
- specify a task when creating a model in VDP
- create a Python model that inherits the corresponding post-processing task class.

If no task is specified when creating a model, the inference output will be in Triton raw message ModelInferResponse format.

#### Supported tasks
Here is a list of tasks that VDP supports.
- TASK_CLASSIFICATION
- TASK_DETECTION

We will continue adding new tasks and make the parser more flexible. If you want to make a request, please feel free to open an issue and describe your use case in details.

##### TASK_CLASSIFICATION
Create a `labels.txt` file to list all the categories, with one category label per line. Include the file in the model configuration.

__`labels.txt` example__
   ```
   cat
   dog
   ```
__`config.pbtxt` output example__
   ```
   ...
   output [
     {
       ...
       label_filename: "labels.txt"
     }
   ]
   ...
   ```
Create a Python file with a structure similar to below:
```python
import numpy as np
from typing import Tuple
from triton_python_model.task.classification import PostClassificationModel


class TritonPythonModel(PostClassificationModel):
    """Your Python model must use the same class name. Every Python model that is created must have "TritonPythonModel" as the class name.
    """
    def __init__(self) -> None:
        """ Constructor function must be implemented in every model. This function initializes the names of the input and output variables in the model configuration.
        """
        # super().__init__(input_names=[...], output_names=[...])

    def post_process_per_image(self, inputs: Tuple[np.ndarray]) -> np.ndarray:
        """`post_process_per_image` must be implemented in every Python model. This function receives a sequence of the input array of the model for one image of a batch, converts and returns the an array that represents the classification scores `scores` for this image.

        Parameters
        ----------
        inputs: Tuple[np.ndarray]
          a sequence of Input array of one image

        Returns
        -------
        np.ndarray
          classification score array `scores` of this image. The shape of `scores` should be (n,), where `n` is the number of categories.
        """
        # return np.array([0.4, 0.6]) # Dummy example of classification with 2 classes
```
__Standardised output example__
```
{
  "output": [
    {
      "classification_outputs": [
        {
          "category": "golden retriever",
          "score": 0.896806
        }
      ]
    }
  ]
}
```

##### TASK_DETECTION
Create a Python file with a structure similar to below:
```python
import numpy as np
from typing import Tuple
from triton_python_model.task.detection import PostDetectionModel


class TritonPythonModel(PostDetectionModel):
    """Your Python model must use the same class name. Every Python model that is created must have "TritonPythonModel" as the class name.
    """
    def __init__(self) -> None:
        """ Constructor function must be implemented in every model. This function initializes the names of the input and output variables in the model configuration.
        """
        # super().__init__(input_names=[...], output_names=[...])

    def post_process_per_image(self, inputs: Tuple[np.ndarray]) -> Tuple[np.ndarray, np.ndarray]:
        """`post_process_per_image` must be implemented in every Python model. This function receives a sequence of the input array of the model for one image of a batch, converts and returns the a sequence of array `bboxes` and `labels`. `bboxes` represents the detected bounding boxes and scores. `labels` represents the corresponding category label for each bounding box.

        Parameters
        ----------
        inputs: Tuple[np.ndarray]
          a sequence of Input array of one image

        Returns
        -------
        Tuple[np.ndarray]
          - `bboxes`: bounding boxes detected in this image with shape (n,5) or (0,). The bounding box format is [x1, y1, x2, y2, score] in the image.
          - `labels`: labels corresponding to the bounding boxes with shape (n,) or (0,), where `n` is the number of categories.

          The length of `bboxes` must be the same as that of `labels`.
          -
        """
        # return np.array([[2, 5, 10, 20, 0.98]]), np.array(["cat"]) # Dummy detection example
```
__Standardised output example__
```
{
  "output": [
    {
      "detection_outputs": [
        {
          "bounding_box_objects": [
            {
              "bounding_box": {
                "height": 402.58002,
                "left": 325.79257,
                "top": 99.084984,
                "width": 204.18991
              },
              "category": "dog",
              "score": 0.980409
            },
            {
              "bounding_box": {
                "height": 242.36629,
                "left": 133.76926,
                "top": 195.17857,
                "width": 207.4065
              },
              "category": "dog",
              "score": 0.9009272
            }
          ]
        }
      ]
    }
  ]
}
```
