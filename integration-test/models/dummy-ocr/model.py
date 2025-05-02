from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_ocr_to_vision_input,
    construct_task_ocr_output,
)


@instill_deployment
class OCR:
    def __init__(self):
        pass

    async def __call__(self, request):

        vision_inputs = await parse_task_ocr_to_vision_input(request=request)

        input_len = len(vision_inputs)

        texts = [["words" for _ in range(input_len)]]
        scores = [[0.99 for _ in range(input_len)]]
        bboxes = [[[0, 0, 0, 0]] for _ in range(input_len)]

        return construct_task_ocr_output(
            request=request,
            texts=texts,
            scores=scores,
            bounding_boxes=bboxes,
        )


entrypoint = InstillDeployable(OCR).get_deployment_handle()
