import http from "k6/http";
import {
    group,
} from "k6";
import {
    FormData
} from "https://jslib.k6.io/formdata/0.0.2/index.js";
import encoding from "k6/encoding";
import {
    textSummary
} from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

import * as constant from "./const.js"
import * as verify from "./verify-semantic-segmentation.js"
import * as helper from "./helper.js"

const model = "semantic-segmentation";
const modelRepository = "instill-ai/model-semantic-segmentation-dvc";

let modelInstances
if (__ENV.TEST_CPU_ONLY) {
    modelInstances = [
        `models/${model}/instances/v1.0-cpu`,
    ]
} else if (__ENV.TEST_GPU_ONLY) {
    modelInstances = [
        `models/${model}/instances/v1.0-gpu`,
    ]
} else {
    modelInstances = [
        `models/${model}/instances/v1.0-cpu`,
        `models/${model}/instances/v1.0-gpu`,
    ]
}

export let options = {
    setupTimeout: '30000s',
    insecureSkipTLSVerify: true,
    thresholds: {
        checks: ["rate == 1.0"],
    },
};

export function setup() {
    if (__ENV.MODE == "demo") {
    } else {
        helper.setupConnectors()
        helper.deployModel(model, modelRepository, modelInstances)
        helper.createPipeline(model, modelInstances)
    }
}

export default function () {
    group("Trigger: Semantic Segmentation model", function () {

        verify.verifySemanticSegmentation(`${model}`, "url", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "semantic_segmentation": {
                    "image_url": "https://artifacts.instill.tech/imgs/street.png",
                }
            }, {
                "semantic_segmentation": {
                    "image_url": "https://artifacts.instill.tech/imgs/street2.png",
                }
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
        }))

        verify.verifySemanticSegmentation(`${model}`, "base64", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "semantic_segmentation": {
                    "image_base64": encoding.b64encode(constant.streetImg, "b"),
                },
            }, {
                "semantic_segmentation": {
                    "image_base64": encoding.b64encode(constant.street2Img, "b"),
                },
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
        }))

        var fd = new FormData();
        fd.append("file", http.file(constant.streetImg, "street.png"));
        fd.append("file", http.file(constant.street2Img, "street2.png"));
        verify.verifySemanticSegmentation(`${model}`, "form_data", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger-multipart`, fd.body(), {
            headers: {
                "Content-Type": `multipart/form-data; boundary=${fd.boundary}`,
            },
        }))

    });
}

export function teardown(data) {
    if (__ENV.MODE == "demo") {
    } else {
        helper.cleanup(model)
    }
}

export function handleSummary(data) {
    if (__ENV.NOTIFICATION == "true") {
        helper.sendSlackMessages(data);
    }
    return {
        stdout: textSummary(data, {
            indent: "→",
            enableColors: true
        }),
    };
}