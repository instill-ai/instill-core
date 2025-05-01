from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_detection_to_vision_input,
    construct_task_detection_output,
)


@instill_deployment
class Det:
    def __init__(self):
        pass

    async def __call__(self, request):
        vision_inputs = await parse_task_detection_to_vision_input(request=request)

        input_len = len(vision_inputs)

        bboxes = [[[0, 0, 0, 0]] for _ in range(input_len)]
        scores = [[1.0] for _ in range(input_len)]
        labels = [["dummy_class"] for _ in range(input_len)]

        return construct_task_detection_output(
            request=request,
            categories=labels,
            scores=scores,
            bounding_boxes=bboxes,
        )


entrypoint = InstillDeployable(Det).get_deployment_handle()
