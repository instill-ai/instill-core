import http from "k6/http";
import {
    group,
} from "k6";
import {
    FormData
} from "https://jslib.k6.io/formdata/0.0.2/index.js";
import {
    textSummary
} from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

import encoding from "k6/encoding";


import * as constant from "./const.js"
import * as verify from "./verify-classification.js"
import * as helper from "./helper.js"

const model = "mobilenetv2";
const modelRepository = "instill-ai/model-mobilenetv2-dvc";

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
    group("Trigger: MobilenetV2 model", function () {

        verify.verifyClassification(`${model}`, "url", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "classification": {
                    "image_url": "https://artifacts.instill.tech/imgs/dog.jpg",
                }
            }, {
                "classification": {
                    "image_url": "https://artifacts.instill.tech/imgs/bear.jpg",
                }
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
        }))

        verify.verifyClassification(`${model}`, "base64", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "classification": {
                    "image_base64": encoding.b64encode(constant.dogImg, "b"),
                },
            }, {
                "classification": {
                    "image_base64": encoding.b64encode(constant.bearImg, "b"),
                },
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
        }))

        var fd = new FormData();
        fd.append("file", http.file(constant.dogImg, "dog.jpg"));
        fd.append("file", http.file(constant.bearImg, "bear.jpg"));
        verify.verifyClassification(`${model}`, "form_data", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger-multipart`, fd.body(), {
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