import time
from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_completion_to_completion_input,
    construct_task_completion_output,
)


@instill_deployment
class Completion:
    def __init__(self):
        pass

    async def __call__(self, request):
        inputs = await parse_task_completion_to_completion_input(request=request)

        input_len = len(inputs)

        finish_reasons = [["length"] for _ in range(input_len)]
        indexes = [list(range(input_len))]
        created = [[int(time.time())] for _ in range(input_len)]
        contents = [[inputs[i].prompt] for i in range(input_len)]

        return construct_task_completion_output(
            request=request,
            finish_reasons=finish_reasons,
            indexes=indexes,
            created_timestamps=created,
            contents=contents,
        )


entrypoint = InstillDeployable(Completion).get_deployment_handle()
