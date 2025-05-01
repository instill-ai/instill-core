from instill.helpers.const import DataType
from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    construct_infer_response,
    construct_metadata_response,
    Metadata,
)

import numpy as np


@instill_deployment
class ImageToImage:
    def __init__(self):
        pass

    def ModelMetadata(self, req):
        resp = construct_metadata_response(
            req=req,
            inputs=[
                Metadata(
                    name="prompt",
                    datatype=str(DataType.TYPE_STRING.name),
                    shape=[1],
                ),
                Metadata(
                    name="negative_prompt",
                    datatype=str(DataType.TYPE_STRING.name),
                    shape=[1],
                ),
                Metadata(
                    name="prompt_image",
                    datatype=str(DataType.TYPE_STRING.name),
                    shape=[1],
                ),
                Metadata(
                    name="samples",
                    datatype=str(DataType.TYPE_INT32.name),
                    shape=[1],
                ),
                Metadata(
                    name="scheduler",
                    datatype=str(DataType.TYPE_STRING.name),
                    shape=[1],
                ),
                Metadata(
                    name="steps",
                    datatype=str(DataType.TYPE_INT32.name),
                    shape=[1],
                ),
                Metadata(
                    name="guidance_scale",
                    datatype=str(DataType.TYPE_FP32.name),
                    shape=[1],
                ),
                Metadata(
                    name="seed",
                    datatype=str(DataType.TYPE_INT64.name),
                    shape=[1],
                ),
                Metadata(
                    name="extra_params",
                    datatype=str(DataType.TYPE_STRING.name),
                    shape=[1],
                ),
            ],
            outputs=[
                Metadata(
                    name="images",
                    datatype=str(DataType.TYPE_FP32.name),
                    shape=[-1, -1, -1, -1],
                ),
            ],
        )
        return resp

    async def __call__(self, req):
        resp_outputs = []
        resp_raw_outputs = []
        for _ in req.raw_input_contents:
            image = np.zeros([1, 5, 5, 3], dtype=np.float32).tobytes()

            resp_outputs.append(
                Metadata(
                    name="images",
                    shape=[1, 5, 5, 3],
                    datatype=str(DataType.TYPE_STRING),
                )
            )

            resp_raw_outputs.append(image)

        return construct_infer_response(
            req=req,
            outputs=resp_outputs,
            raw_outputs=resp_raw_outputs,
        )


entrypoint = InstillDeployable(ImageToImage).get_deployment_handle()
