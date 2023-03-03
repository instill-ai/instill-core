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

import * as constant from "./const.js"
import * as verify from "./verify-gpt2.js"
import * as helper from "./helper.js"

const model = "gpt2";
const modelRepository = "instill-ai/model-gpt2-megatron-dvc";

let modelInstances = [
    `models/${model}/instances/fp32-345m-4-gpu`,
]

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
    group("Inference: GPT2 model", function () {
        verify.verifyGPT2(`${model}`, "url", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger`, JSON.stringify({
            "task_inputs": [{
                "text_generation": {
                    "prompt": "Instill AI is",
                },
            }]
        }), {
            headers: {
                "Content-Type": "application/json",
            },
            timeout: '600s',
        }))

        var fd = new FormData();
        fd.append("prompt", "Instill AI is");
        verify.verifyGPT2(`${model}`, "form_data", modelInstances, http.request("POST", `${constant.apiHost}/v1alpha/pipelines/${model}/trigger-multipart`, fd.body(), {
            headers: {
                "Content-Type": `multipart/form-data; boundary=${fd.boundary}`,
            },
            timeout: '600s'
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