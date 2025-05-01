import time
from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_chat_to_multimodal_chat_input,
    construct_task_chat_output,
)


@instill_deployment
class MultimodalChat:
    def __init__(self):
        pass

    async def __call__(self, request):
        inputs = await parse_task_chat_to_multimodal_chat_input(request=request)

        input_len = len(inputs)

        finish_reasons = [["length"] for _ in range(input_len)]
        indexes = [list(range(input_len))]
        created = [[int(time.time())] for _ in range(input_len)]
        messages = [
            [{"content": inputs[i].messages[-1]["content"], "role": "assistant"}]
            for i in range(input_len)
        ]

        return construct_task_chat_output(
            request=request,
            finish_reasons=finish_reasons,
            indexes=indexes,
            created_timestamps=created,
            messages=messages,
        )


entrypoint = InstillDeployable(MultimodalChat).get_deployment_handle()
