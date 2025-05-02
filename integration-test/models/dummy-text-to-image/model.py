from instill.helpers.ray_config import instill_deployment, InstillDeployable
from instill.helpers import (
    parse_task_text_to_image_input,
    construct_task_text_to_image_output,
)


@instill_deployment
class TextToImage:
    def __init__(self):
        pass

    async def __call__(self, request):

        inputs = await parse_task_text_to_image_input(request=request)

        input_len = len(inputs)

        finish_reasons = [["success"] for _ in range(input_len)]
        images = [
            [
                "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC"
            ]
            for _ in range(input_len)
        ]

        return construct_task_text_to_image_output(
            request=request,
            finish_reasons=finish_reasons,
            images=images,
        )


entrypoint = InstillDeployable(TextToImage).get_deployment_handle()
