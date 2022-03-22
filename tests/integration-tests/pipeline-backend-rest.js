import http from "k6/http";
import { sleep, check, group, fail } from "k6";
import { FormData } from "https://jslib.k6.io/formdata/0.0.2/index.js";
import { randomString } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import { URL } from "https://jslib.k6.io/url/1.0.0/index.js";

import {
  genHeader,
} from "./helpers.js";

import * as pipelineConstants from "./pipeline-backend-constants.js";

const pipelineHost = "http://localhost:8446";
const modelHost = "http://localhost:8445";

const model_name = pipelineConstants.detectionModel.name;
const det_model = open(`${__ENV.TEST_FOLDER_ABS_PATH}/tests/integration-tests/data/dummy-det-model.zip`, "b");

export let options = {
  insecureSkipTLSVerify: true,
  thresholds: {
    checks: ["rate == 1.0"],
  },
};

export function setup() {
  // Prepare sample model in model-backend
  {
    group("Model Backend API: Create detection model", function () {
      let fd = new FormData();
      fd.append("name", model_name);
      fd.append("description", randomString(20));
      fd.append("task", "TASK_DETECTION");
      fd.append("content", http.file(det_model, "dummy-det-model.zip"));
      check(http.request("POST", `${modelHost}/models/upload`, fd.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
      }), {
        "POST /models/upload (multipart) det response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models/upload (multipart) task det response model.name": (r) =>
          r.json().model.name !== undefined,
          "POST /models/upload (multipart) task det response model.full_name": (r) =>
          r.json().model.full_name !== undefined,
          "POST /models/upload (multipart) task det response model.task": (r) =>
          r.json().model.task === "TASK_DETECTION",
          "POST /models/upload (multipart) task det response model.model_versions.length": (r) =>
          r.json().model.model_versions.length === 1,
      });

      let payload = JSON.stringify({
        "status": "STATUS_ONLINE",
      });
      check(http.patch(`${modelHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH /models/${model_name}/versions/1 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH /models/${model_name}/versions/1 online task cls response model_version.version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH /models/${model_name}/versions/1 online task cls response model_version.model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH /models/${model_name}/versions/1 online task cls response model_version.description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH /models/${model_name}/versions/1 online task cls response model_version.created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH /models/${model_name}/versions/1 online task cls response model_version.updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH /models/${model_name}/versions/1 online task cls response model_version.status`]: (r) =>
          r.json().model_version.status === "STATUS_ONLINE",
      });
    });
  }
}

export default function (data) {
  let resp;

  /*
   * Pipelines API - API CALLS
   */

  // Health check
  {
    group("Pipelines API: Health check", () => {
      check(http.request("GET", `${pipelineHost}/health/pipeline`), {
        "GET /health/pipelines response status is 200": (r) => r.status === 200,
      });
    });
  }

  // Create Pipelines
  {
    let createPipelineEntity = Object.assign(
      {
        name: randomString(100),
        description: randomString(512),
        active: true,
      },
      pipelineConstants.detectionRecipe
    );

    group("Pipelines API: Create pipeline with sample model", () => {
      resp = http.request(
        "POST",
        `${pipelineHost}/pipelines`,
        JSON.stringify(createPipelineEntity),
        {
          headers: genHeader("application/json"),
        }
      );
      check(resp, {
        "POST /pipelines response status is 201": (r) => r.status === 201,
        "POST /pipelines response pipeline.name": (r) => r.json().pipeline.name !== undefined,
      });
      check(
        http.request("POST", `${pipelineHost}/pipelines`, JSON.stringify({}), {
          headers: genHeader("application/json"),
        }),
        {
          "POST /pipelines with empty body response status is 400": (r) => r.status === 400,
        }
      );
      check(
        http.request("POST", `${pipelineHost}/pipelines`, null, {
          headers: genHeader("application/json"),
        }),
        {
          "POST /pipelines with null body response status is 400": (r) => r.status === 400,
        }
      );
    });

    group("Pipelines API: List pipelines", () => {
      check(
        http.request("GET", `${pipelineHost}/pipelines`, null, {
          headers: genHeader("application/json"),
        }),
        {
          "GET /pipelines (url) response status is 200": (r) => r.status === 200,
          "GET /pipelines response pipelines.length >= 1": (r) => r.json().pipelines.length >= 1,
          "GET /pipelines response pipelines[0] should not have recipe": (r) => r.json().pipelines[0].recipe === undefined || r.json().pipelines[0].recipe == null,
        }
      );
      const url = new URL(`${pipelineHost}/pipelines`);
      url.searchParams.append("view", 2);
      check(
        http.request("GET", url.toString(), null, {
          headers: genHeader("application/json"),
        }),
        {
          "GET /pipelines (url) response status is 200": (r) =>
            r.status === 200,
          "GET /pipelines response pipeline[0] should have recipe": (
            r
          ) => r.json().pipelines[0].recipe !== undefined,
        }
      );
    });

    group("Pipelines API: Get a pipeline", () => {
      check(
        http.request(
          "GET",
          `${pipelineHost}/pipelines/${resp.json("pipeline.name")}`,
          null,
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`GET /pipelines/${resp.json("pipeline.name")} response status is 200`]: (r) => r.status === 200,
          [`GET /pipelines/${resp.json("pipeline.name")} response pipeline.name`]: (r) => r.json().pipeline.name === createPipelineEntity.name,
          [`GET /pipelines/${resp.json("pipeline.name")} response pipeline.description`]: (r) => r.json().pipeline.description === createPipelineEntity.description,
          [`GET /pipelines/${resp.json("pipeline.name")} response pipeline.id`]: (r) => r.json().pipeline.id !== undefined,
          [`GET /pipelines/${resp.json("pipeline.name")} response pipeline.recipe`]: (r) => r.json().pipeline.recipe !== undefined,
        }
      );
      check(
        http.request("GET", `${pipelineHost}/pipelines/non_exist_id`, null, {
          headers: genHeader("application/json"),
        }),
        {
          "GET /pipelines/non_exist_id response status is 404": (r) =>
            r.status === 404,
        }
      );
    });

    let updatePipelineEntity = Object.assign(
      {
        description: randomString(512),
        active: true,
      },
    );
    group("Pipelines API: Update a pipeline", () => {
      check(
        http.request(
          "PATCH",
          `${pipelineHost}/pipelines/${resp.json("pipeline.name")}`,
          JSON.stringify(updatePipelineEntity),
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`PATCH /pipelines/${resp.json("pipeline.name")} response status is 200`]: (r) => r.status === 200,
          [`PATCH /pipelines/${resp.json("pipeline.name")} response pipeline.name`]: (r) => r.json().pipeline.name === createPipelineEntity.name,
          [`PATCH /pipelines/${resp.json("pipeline.name")} response pipeline.description`]: (r) => r.json().pipeline.description === updatePipelineEntity.description,
          [`PATCH /pipelines/${resp.json("pipeline.name")} response pipeline.id`]: (r) => r.json().pipeline.id !== undefined,
          [`PATCH /pipelines/${resp.json("pipeline.name")} response pipeline.recipe`]: (r) => r.json().pipeline.recipe !== undefined,
        }
      );
      check(
        http.request(
          "PATCH",
          `${pipelineHost}/pipelines/${resp.json("pipeline.name")}`,
          null,
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`PATCH /pipelines/${resp.json("pipeline.name")} response status is 200`]:
            (r) => r.status === 200,
        }
      );
      check(
        http.request(
          "PATCH",
          `${pipelineHost}/pipelines/non_exist_id`,
          JSON.stringify(updatePipelineEntity),
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          "PATCH /pipelines/non_exist_id response status is 404": (r) =>
            r.status === 404,
        }
      );
    });

    group("Pipelines API: Trigger a pipeline", () => {
      // url data
      check(
        http.request(
          "POST",
          `${pipelineHost}/pipelines/${resp.json("pipeline.name")}/outputs`,
          JSON.stringify(pipelineConstants.triggerPipelineJSONUrl),
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (url) response status is 200`]: (r) => r.status === 200,
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (url) response output.detection_outputs.length`]: (r) =>
            r.json().output.detection_outputs.length === 1,
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (url) response output.detection_outputs[0].bounding_box_objects.length`]: (r) =>
            r.json().output.detection_outputs[0].bounding_box_objects.length === 1,
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (url) response output.detection_outputs[0].bounding_box_objects[0].category`]: (r) =>
            r.json().output.detection_outputs[0].bounding_box_objects[0].category === "test",
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (url) response output.detection_outputs[0].bounding_box_objects[0].score`]: (r) =>
            r.json().output.detection_outputs[0].bounding_box_objects[0].score === 1,
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (url) response output.detection_outputs[0].bounding_box_objects[0].bounding_box`]: (r) =>
            r.json().output.detection_outputs[0].bounding_box_objects[0].bounding_box !== undefined,
        }
      );

      // base64 data
      check(
        http.request(
          "POST",
          `${pipelineHost}/pipelines/${resp.json("pipeline.name")}/outputs`,
          JSON.stringify(pipelineConstants.triggerPipelineJSONBase64),
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (base64) response status is 200`]: (r) => r.status === 200,
        }
      );

      // multipart data
      const fd = new FormData();
      fd.append("contents", http.file(pipelineConstants.dogImg));
      check(
        http.request(
          "POST",
          `${pipelineHost}/pipelines/${resp.json("pipeline.name")}/upload/outputs`,
          fd.body(),
          {
            headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
          }
        ),
        {
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (multipart) response status is 200`]: (r) => r.status === 200,
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (multipart) response output.detection_outputs.length`]: (r) => r.json().output.detection_outputs.length === 1,
          [`POST /pipelines/${resp.json("pipeline.name")}/outputs (multipart) response output.detection_outputs[0].bounding_box_objects[0].score`]: (r) => r.json().output.detection_outputs[0].bounding_box_objects[0].score !== undefined,
        }
      );
    });
  }

  sleep(1);
}

export function teardown(data) {
  group("Pipeline API: Delete all pipelines created by this test", () => {
    for (const pipeline of http
      .request("GET", `${pipelineHost}/pipelines`, null, {
        headers: genHeader(
          "application/json"
        ),
      })
      .json("pipelines")) {
      check(pipeline, {
        "GET /clients response contents[*] id": (c) => c.id !== undefined,
      });

      check(
        http.request("DELETE", `${pipelineHost}/pipelines/${pipeline.name}`, null, {
          headers: genHeader("application/json"),
        }),
        {
          [`DELETE /pipelines/${pipeline.name} response status is 204`]: (r) =>
            r.status === 204,
        }
      );
    }

    check(http.request("DELETE", `${modelHost}/models/${model_name}`, null, {
      headers: genHeader(`application/json`),
    }), {
      "DELETE clean up response status": (r) =>
        r.status === 200 // TODO: update status to 201
    });
  });
}
