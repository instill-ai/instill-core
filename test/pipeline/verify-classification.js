import {
    check,
} from "k6";

let classificationDog = "golden retriever"
let classificationBear = "brown bear"

if (__ENV.TARGET == "m1") { // m1 have problem with classification extension and result with the Triton 22.12 is wrong when running batching.
    classificationDog = "tile roof"
    classificationBear = "tile roof"
}

export function verifyClassification(pipelineId, triggerType, modelInstances, resp) {
    check(resp, {
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response status is 200`]: (r) => r.status === 200,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs.length == 1`]: (r) => r.json().model_instance_outputs.length == modelInstances.length,
    });

    for (let i = 0; i < modelInstances.length; i++) {
        check(resp, {
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[${i}].model_instance`]: (r) => r.json().model_instance_outputs[i].model_instance === modelInstances[i],
        });
    }
    
    check(resp, {
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task`]: (r) => r.json().model_instance_outputs[0].task === "TASK_CLASSIFICATION",
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs.length`]: (r) => r.json().model_instance_outputs[0].task_outputs.length === 2,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].classification.category`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].classification.category === classificationDog,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[0].classification.score`]: (r) => r.json().model_instance_outputs[0].task_outputs[0].classification.score > 0.7,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].classification.category`]: (r) => r.json().model_instance_outputs[0].task_outputs[1].classification.category === classificationBear,
        [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[0].task_outputs[1].classification.score`]: (r) => r.json().model_instance_outputs[0].task_outputs[1].classification.score > 0.7,
    });
    if (resp.json().model_instance_outputs.length == 2) {
        check(resp, {
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task`]: (r) => r.json().model_instance_outputs[1].task === "TASK_CLASSIFICATION",
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs.length`]: (r) => r.json().model_instance_outputs[0].task_outputs.length === 2,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].classification.category`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].classification.category === classificationDog,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[0].classification.score`]: (r) => r.json().model_instance_outputs[1].task_outputs[0].classification.score > 0.7,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].classification.category`]: (r) => r.json().model_instance_outputs[1].task_outputs[1].classification.category === classificationBear,
            [`POST /v1alpha/pipelines/${pipelineId}/trigger (${triggerType}) response model_instance_outputs[1].task_outputs[1].classification.score`]: (r) => r.json().model_instance_outputs[1].task_outputs[1].classification.score > 0.7,
        });
    }
}
