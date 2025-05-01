from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_keypoint_to_vision_input,
    construct_task_keypoint_output,
)


@instill_deployment
class Keypoint:
    def __init__(self):
        pass

    async def __call__(self, request):

        vision_inputs = await parse_task_keypoint_to_vision_input(request=request)

        input_len = len(vision_inputs)

        kps = [[i, i, 1] for i in range(17)]
        kpoints = [[kps] for _ in range(input_len)]
        bboxes = [[[0, 0, 0, 0]] for _ in range(input_len)]
        scores = [[1.0] for _ in range(input_len)]

        return construct_task_keypoint_output(
            request=request,
            keypoints=kpoints,
            scores=scores,
            bounding_boxes=bboxes,
        )


entrypoint = InstillDeployable(Keypoint).get_deployment_handle()
