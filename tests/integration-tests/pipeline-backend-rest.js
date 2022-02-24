import http from "k6/http";
import { sleep, check, group, fail } from "k6";
import { FormData } from "https://jslib.k6.io/formdata/0.0.2/index.js";
import { randomString } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import { URL } from "https://jslib.k6.io/url/1.0.0/index.js";

import {
  genHeader,
} from "./helpers.js";

import * as pipelineConstants from "./pipeline-backend-constants.js";

const pipelineHost = "http://127.0.0.1:8446";
const modelHost = "http://127.0.0.1:8445";

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
      fd.append("cvtask", "det");
      fd.append("content", http.file(det_model, "dummy-det-model.zip"));
      check(http.request("POST", `${modelHost}/models/upload`, fd.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
      }), {
        "POST /models/upload (multipart) det response Status": (r) =>
          r.status === 200,
        "POST /models/upload (multipart) cvtask det response Name": (r) =>
          r.json().Name !== undefined,
        "POST /models/upload (multipart) cvtask det response FullName": (r) =>
          r.json().FullName !== undefined,
        "POST /models/upload (multipart) cvtask det response CVTask": (r) =>
          r.json().CVTask === "DETECTION",
        "POST /models/upload (multipart) cvtask det response Versions": (r) =>
          r.json().Versions.length > 0,
      });

      let payload = JSON.stringify({
        "model": { "status": 1 },
        "update_mask": "status"
      });
      check(http.patch(`${modelHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH /models/${model_name}/versions/1 det response Status`]: (r) =>
          r.status === 200,
        [`PATCH /models/${model_name}/versions/1 det response Name`]: (r) =>
          r.json().name !== undefined,
        [`PATCH /models/${model_name}/versions/1 det response FullName`]: (r) =>
          r.json().full_Name !== undefined,
        [`PATCH /models/${model_name}/versions/1 det response CVTask`]: (r) =>
          r.json().cv_task === "DETECTION",
        [`PATCH /models/${model_name}/versions/1 det response Versions`]: (r) =>
          r.json().versions.length > 0,
        [`PATCH /models/${model_name}/versions/1 det response Version 1 Status`]: (r) =>
          r.json().versions[0].status === "ONLINE",
      });
    });
  }
}

const dogImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/tests/integration-tests/data/dog.jpg`, "b");

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
        "POST /pipelines response id check": (r) => r.json("name") !== undefined,
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
          "GET /pipelines response contents >= 1": (r) => r.json("contents").length >= 1,
          "GET /pipelines response contents should not have recipe": (r) => r.json("contents")[0].recipe === undefined || r.json("contents")[0].recipe == null,
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
          "GET /pipelines response contents should have recipe": (
            r
          ) => r.json("contents")[0].recipe !== undefined,
        }
      );
    });

    group("Pipelines API: Get a pipeline", () => {
      check(
        http.request(
          "GET",
          `${pipelineHost}/pipelines/${resp.json("name")}`,
          null,
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`GET /pipelines/${resp.json("name")} response status is 200`]: (r) => r.status === 200,
          [`GET /pipelines/${resp.json("name")} response name`]: (r) => r.json("name") === createPipelineEntity.name,
          [`GET /pipelines/${resp.json("name")} response description`]: (r) => r.json("description") === createPipelineEntity.description,
          [`GET /pipelines/${resp.json("name")} response id`]: (r) => r.json("id") !== undefined,
          [`GET /pipelines/${resp.json("name")} response recipe`]: (r) => r.json("recipe") !== undefined,
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
          `${pipelineHost}/pipelines/${resp.json("name")}`,
          JSON.stringify(updatePipelineEntity),
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`PATCH /pipelines/${resp.json("name")} response status is 200`]: (r) => r.status === 200,
          [`PATCH /pipelines/${resp.json("name")} response name`]: (r) => r.json("name") === createPipelineEntity.name,
          [`PATCH /pipelines/${resp.json("name")} response description`]: (r) => r.json("description") === updatePipelineEntity.description,
          [`PATCH /pipelines/${resp.json("name")} response id`]: (r) => r.json("id") !== undefined,
          [`PATCH /pipelines/${resp.json("name")} response recipe`]: (r) => r.json("recipe") !== undefined,
        }
      );
      check(
        http.request(
          "PATCH",
          `${pipelineHost}/pipelines/${resp.json("name")}`,
          null,
          {
            headers: genHeader("application/json"),
          }
        ),
        {
          [`PATCH /pipelines/${resp.json("name")} response status is 200`]:
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
      // multipart data
      const fd = new FormData();
      fd.append("contents", http.file(dogImg));
      check(
        http.request(
          "POST",
          `${pipelineHost}/pipelines/${resp.json("name")}/upload/outputs`,
          fd.body(),
          {
            headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
          }
        ),
        {
          [`POST /pipelines/${resp.json("name")}/outputs (url) response status is 200`]: (r) => r.status === 200,
          [`POST /pipelines/${resp.json("name")}/outputs (url) response contents.length`]: (r) => r.json("contents").length === 1,
          [`POST /pipelines/${resp.json("name")}/outputs (url) response contents[0].contents[0].score`]: (r) => r.json("contents")[0].contents[0].score !== undefined,
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
      .json("contents")) {
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
      "DELETE clean up response Status": (r) =>
        r.status === 200 // TODO: update status to 201
    });
  });
}
