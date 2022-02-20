import http from "k6/http";
import {sleep, check, group, fail} from "k6";
import {FormData} from "https://jslib.k6.io/formdata/0.0.2/index.js";
import {randomString} from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import {URL} from "https://jslib.k6.io/url/1.0.0/index.js";

import {
  genHeader,
} from "./helpers.js";

import * as pipelineConstants from "./pipeline-backend-constants.js";

const apiHost = "http://127.0.0.1:8446";

export let options = {
  insecureSkipTLSVerify: true,
  thresholds: {
    checks: ["rate == 1.0"],
  },
};

export function setup() {
}

const dogImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/dog.jpg`, "b");

export default function (data) {
  let resp;

  /*
   * Pipelines API - API CALLS
   */

  // Health check
  {
    group("Pipelines API: Health check", () => {
      check(http.request("GET", `${apiHost}/health/pipeline`), {
        "GET /health/pipelines response status is 200": (r) => r.status === 200,
      });
    });
  }

  // Create Pipelines
  {
    let createPipelineEntity = Object.assign(
      {
        name: randomString(256),
        description: randomString(512),
        active: true,
      },
      pipelineConstants.detectionRecipe
    );
    group("Pipelines API: Create pipeline with sample model", () => {
      resp = http.request(
        "POST",
        `${apiHost}/pipelines`,
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
        http.request("POST", `${apiHost}/pipelines`, JSON.stringify({}), {
          headers: genHeader("application/json"),
        }),
        {
          "POST /pipelines with empty body response status is 400": (r) => r.status === 400,
        }
      );
      check(
        http.request("POST", `${apiHost}/pipelines`, null, {
          headers: genHeader("application/json"),
        }),
        {
          "POST /pipelines with null body response status is 400": (r) => r.status === 400,
        }
      );
    });

    group("Pipelines API: List pipelines", () => {
      check(
        http.request("GET", `${apiHost}/pipelines`, null, {
          headers: genHeader("application/json"),
        }),
        {
          "GET /pipelines (url) response status is 200": (r) => r.status === 200,
          "GET /pipelines response contents >= 1": (r) => r.json("contents").length >= 1,
          "GET /pipelines response contents should not have recipe": (r) => r.json("contents")[0].recipe === undefined || r.json("contents")[0].recipe == null,
        }
      );
      const url = new URL(`${apiHost}/pipelines`);
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
          `${apiHost}/pipelines/${resp.json("name")}`,
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
        http.request("GET", `${apiHost}/pipelines/non_exist_id`, null, {
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
          `${apiHost}/pipelines/${resp.json("name")}`,
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
          `${apiHost}/pipelines/${resp.json("name")}`,
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
          `${apiHost}/pipelines/non_exist_id`,
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

    group("Pipelines API: Trigger a pipeline with classification model", () => {
      // multipart data
      const fd = new FormData();
      fd.append("contents", http.file(dogImg));
      check(
        http.request(
          "POST",
          `${apiHost}/pipelines/${resp.json("name")}/upload/outputs`,
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
      .request("GET", `${apiHost}/pipelines`, null, {
        headers: genHeader(
          "application/json"
        ),
      })
      .json("contents")) {
      check(pipeline, {
        "GET /clients response contents[*] id": (c) => c.id !== undefined,
      });

      check(
        http.request("DELETE", `${apiHost}/pipelines/${pipeline.name}`, null, {
          headers: genHeader("application/json"),
        }),
        {
          [`DELETE /pipelines/${pipeline.name} response status is 204`]: (r) =>
            r.status === 204,
        }
      );
    }
  });
}
