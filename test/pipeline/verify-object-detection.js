import {
    check,
} from "k6";


export function verifyDetection(pipelineId, triggerType, modelInstances, resp) {
    check((resp), {
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response status is 200`]: (r) => r.status === 200,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs.length == modelInstances.length`]: (r) => r.json().model_instance_outputs.length == modelInstances.length,
    });
    for (let i = 0; i < modelInstances.length; i++) {
        check(resp, {
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[${i}].model_instance`]: (r) => r.json().model_instance_outputs[i].model_instance === modelInstances[i],
        });
    }

    check(resp, {
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task`]: (r) => r.json().model_instance_outputs[0].task === "TASK_DETECTION",
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs.length`]: (r) => r.json().model_instance_outputs[0].task_outputs.length === 2,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects.length`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].detection.objects.length === 2,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[0].category`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].detection.objects[0].category === "dog",
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[0].score`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].detection.objects[0].score > 0.7,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.top`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.top - 100) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.left`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.left - 325) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.width`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.width - 208) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.height`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[0].bounding_box.height - 405) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[1].category`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].detection.objects[1].category === "dog",
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[1].score`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].detection.objects[1].score > 0.7,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.top`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.top - 198) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.left`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.left - 130) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.width`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.width - 198) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.height`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[0].detection.objects[1].bounding_box.height - 235) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects.length`]: (r) => r.json().model_instance_outputs[0].task_outputs[1].detection.objects.length === 1,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects[0].category`]: (r) => r.json().model_instance_outputs[0].task_outputs[1].detection.objects[0].category === "bear",
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects[0].score`]: (r) => r.json().model_instance_outputs[0].task_outputs[1].detection.objects[0].score > 0.7,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.top`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.top - 85) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.left`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.left - 291) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.width`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.width - 554) < 5,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.height`]: (r) => Math.abs(r.json().model_instance_outputs[0].task_outputs[1].detection.objects[0].bounding_box.height - 756) < 5,
    });
    if (resp.json().model_instance_outputs.length == 2) {
        check(resp, {
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task`]: (r) => r.json().model_instance_outputs[1].task === "TASK_DETECTION",
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs.length`]: (r) => r.json().model_instance_outputs[1].task_outputs.length === 2,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects.length`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].detection.objects.length === 2,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[0].category`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].detection.objects[0].category === "dog",
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[0].score`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].detection.objects[0].score > 0.7,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.top`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.top - 100) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.left`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.left - 325) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.width`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.width - 208) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.height`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[0].bounding_box.height - 405) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[1].category`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].detection.objects[1].category === "dog",
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[1].score`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].detection.objects[1].score > 0.7,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.top`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.top - 198) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.left`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.left - 130) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.width`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.width - 198) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.height`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[0].detection.objects[1].bounding_box.height - 235) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects.length`]: (r) => r.json().model_instance_outputs[1].task_outputs[1].detection.objects.length === 1,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects[0].category`]: (r) => r.json().model_instance_outputs[1].task_outputs[1].detection.objects[0].category === "bear",
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects[0].score`]: (r) => r.json().model_instance_outputs[1].task_outputs[1].detection.objects[0].score > 0.7,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.top`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.top - 85) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.left`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.left - 291) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.width`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.width - 554) < 5,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.height`]: (r) => Math.abs(r.json().model_instance_outputs[1].task_outputs[1].detection.objects[0].bounding_box.height - 756) < 5,
        });
    }
}
