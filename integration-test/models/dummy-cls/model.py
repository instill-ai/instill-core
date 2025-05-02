from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_classification_to_vision_input,
    construct_task_classification_output,
)


@instill_deployment
class MobileNet:
    def __init__(self):
        pass

    async def __call__(self, request):
        vision_inputs = await parse_task_classification_to_vision_input(request=request)

        input_len = len(vision_inputs)

        scores = [0.99 for _ in range(input_len)]
        categories = ["dummy_class" for _ in range(input_len)]

        return construct_task_classification_output(
            request=request, categories=categories, scores=scores
        )


entrypoint = InstillDeployable(MobileNet).get_deployment_handle()
