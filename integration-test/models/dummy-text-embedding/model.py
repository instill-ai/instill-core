import time
from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_embedding_to_text_embedding_input,
    construct_task_embedding_output,
)


@instill_deployment
class TextEmbedding:
    def __init__(self):
        pass

    async def __call__(self, request):

        inputs = await parse_task_embedding_to_text_embedding_input(request=request)

        input_len = len(inputs)

        indexes = [list(range(input_len))]
        created = [[int(time.time())] for _ in range(input_len)]
        embeddings = [
            [[0.00001, -0.00001, 0.00002, 0.001230]] for _ in range(input_len)
        ]

        return construct_task_embedding_output(
            request=request,
            indexes=indexes,
            created_timestamps=created,
            embeddings=embeddings,
        )


entrypoint = InstillDeployable(TextEmbedding).get_deployment_handle()
