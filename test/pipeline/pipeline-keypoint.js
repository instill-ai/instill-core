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
import * as verify from "./verify-keypoint.js"
import * as helper from "./helper.js"

const model = "yolov7-pose";
const modelRepository = "instill-ai/model-yolov7-pose-dvc";

let modelInstances = [
    `models/${model}/instances/v1.0-cpu`,
    `models/${model}/instances/v1.0-gpu`,
]
if (__ENV.HOST.includes("localhost")) {
    modelInstances = [
        `models/${model}/instances/v1.0-cpu`,
    ]
} else if (__ENV.HOST.includes("demo.instill.tech")) {
    modelInstances = [
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
    if (!__ENV.HOST.includes("demo.instill.tech")) {
        helper.setupConnectors()
        helper.deployModel(model, modelRepository, modelInstances)
        helper.createPipeline(model, modelInstances)
    }
}

export default function () {
    group("Trigger: Keypoint model", function () {

        verify.verifyKeypoint(`${model}`, "url", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "keypoint": {
                    "image_url": "https://artifacts.instill.tech/imgs/dance.jpg",
                }
            }, {
                "keypoint": {
                    "image_url": "https://artifacts.instill.tech/imgs/dwaynejohnson.jpeg",
                }
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
        }))

        verify.verifyKeypoint(`${model}`, "base64", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "keypoint": {
                    "image_base64": encoding.b64encode(constant.stredanceImgetImg, "b"),
                },
            }, {
                "keypoint": {
                    "image_base64": encoding.b64encode(constant.dwaynejohnsonImg, "b"),
                },
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
        }))

        var fd = new FormData();
        fd.append("file", http.file(constant.danceImg, "dance.jpg"));
        fd.append("file", http.file(constant.dwaynejohnsonImg, "dwaynejohnson.jpeg"));
        verify.verifyKeypoint(`${model}`, "form_data", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger-multipart`, fd.body(), {
            headers: {
                "Content-Type": `multipart/form-data; boundary=${fd.boundary}`,
            },
        }))

    });
}

export function teardown(data) {
    if (!__ENV.HOST.includes("demo.instill.tech")) {
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