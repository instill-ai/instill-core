import http from "k6/http";
import {sleep, check, group, fail} from "k6";
import {FormData} from "https://jslib.k6.io/formdata/0.0.2/index.js";
import {randomString} from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import {URL} from "https://jslib.k6.io/url/1.0.0/index.js";

import {
  genHeader,
  base64_image,
} from "./helpers.js";

const apiHost = "http://127.0.0.1:8445";

const dog_img = open(`${__ENV.TEST_FOLDER_ABS_PATH}/tests/integration-tests/data/dog.jpg`, "b");

const cls_model = open(`${__ENV.TEST_FOLDER_ABS_PATH}/tests/integration-tests/data/dummy-cls-model.zip`, "b");
const det_model = open(`${__ENV.TEST_FOLDER_ABS_PATH}/tests/integration-tests/data/dummy-det-model.zip`, "b");

export let options = {
  insecureSkipTLSVerify: true,
  thresholds: {
    checks: ["rate == 1.0"],
  },
};

export function setup() {
}

export default function (data) {
  let resp;

  /*
   * Model API - API CALLS
   */

  // Health check
  {
    group("Model API: Health check", () => {
      check(http.request("GET", `${apiHost}/health/model`), {
        "GET /health/model response status is 200": (r) => r.status === 200,
      });
    });
  }

  // Model Backend API: upload model
  {
    group("Model Backend API: Upload a model", function () {
      let fd_cls = new FormData();
      let model_name1 = randomString(10)
      fd_cls.append("name", model_name1);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_CLASSIFICATION");
      fd_cls.append("content", http.file(cls_model, "dummy-cls-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) task cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      let fd_det = new FormData();
      let model_name2 = randomString(10)
      fd_det.append("name", model_name2);
      fd_det.append("description", randomString(20));
      fd_det.append("task", "TASK_DETECTION");
      fd_det.append("content", http.file(cls_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_det.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_det.boundary}`),
      }), {
        "POST /models (multipart) task det response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task det response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task det response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task det response task": (r) =>
          r.json().Task === "TASK_DETECTION",
          "POST /models (multipart) task det response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      let fd_undefined = new FormData();
      let model_name3 = randomString(10)
      fd_undefined.append("name", model_name3);
      fd_undefined.append("description", randomString(20));
      fd_undefined.append("content", http.file(cls_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_undefined.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_undefined.boundary}`),
      }), {
        "POST /models (multipart) task undefined response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task undefined response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task undefined response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task undefined response task": (r) =>
          r.json().Task === "TASK_UNSPECIFIED",
          "POST /models (multipart) task undefined response Versions": (r) =>
          r.json().Versions.length === 1,
      });
      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name1}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });
      check(http.request("DELETE", `${apiHost}/models/${model_name2}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });
      check(http.request("DELETE", `${apiHost}/models/${model_name3}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });
    });
  }

  // Model Backend API: auto increase model version
  {
    group("Model Backend API: Auto increase model version", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_CLASSIFICATION");
      fd_cls.append("content", http.file(cls_model, "dummy-cls-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      let fd_det = new FormData();
      fd_det.append("name", model_name);
      fd_det.append("description", randomString(20));
      fd_det.append("task", "TASK_DETECTION");
      fd_det.append("content", http.file(cls_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_det.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_det.boundary}`),
      }), {
        "POST /models (multipart) det response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task det response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task det response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task det response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task det response Versions": (r) =>
          r.json().Versions.length === 2,
      });

      let fd_undefined = new FormData();
      fd_undefined.append("name", model_name);
      fd_undefined.append("description", randomString(20));
      fd_undefined.append("content", http.file(cls_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_undefined.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_undefined.boundary}`),
      }), {
        "POST /models (multipart) undefined response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task undefined response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task undefined response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task undefined response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task undefined response Versions": (r) =>
          r.json().Versions.length === 3,
      });
      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });
    });
  }

  // Model Backend API: load model online
  {
    group("Model Backend API: Load model online", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_CLASSIFICATION");
      fd_cls.append("content", http.file(cls_model, "dummy-cls-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 1,
      });
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 2,
      });

      let payload = JSON.stringify({
        "status": 2,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response Status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_ONLINE",
      });

      payload = JSON.stringify({
        "status": 2,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/2`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_ONLINE",
      });

      payload = JSON.stringify({
        "status": 1,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response Version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 offline task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_OFFLINE",
      });

      // Triton unloading models takes time
      sleep(4)

      payload = JSON.stringify({
        "status": 1,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/2`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response Version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 offline task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_OFFLINE",
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

  // Model Backend API: make inference
  {
    group("Model Backend API: Predict Model with classification model", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_CLASSIFICATION");
      fd_cls.append("content", http.file(cls_model, "dummy-cls-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      let payload = JSON.stringify({
        "status": 2
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_ONLINE",
      });

      // Predict with url
      payload = JSON.stringify({
        "inputs": [{"image_url": "https://artifacts.instill.tech/dog.jpg"}]
      });
      check(http.post(`${apiHost}/models/${model_name}/versions/1/outputs`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs url cls response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url cls contents`]: (r) =>
          r.json().output.classification_outputs.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url cls contents.category`]: (r) =>
          r.json().output.classification_outputs[0].category === "match",
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url cls response contents.score`]: (r) =>
          r.json().output.classification_outputs[0].score === 1,
      });

      // Predict with base64
      payload = JSON.stringify({
        "inputs": [{"image_base64": base64_image,}]
      });
      check(http.post(`${apiHost}/models/${model_name}/versions/1/outputs`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 cls response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 cls contents`]: (r) =>
          r.json().output.classification_outputs.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 cls contents.category`]: (r) =>
          r.json().output.classification_outputs[0].category === "match",
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 cls response contents.score`]: (r) =>
          r.json().output.classification_outputs[0].score === 1,
      });

      // Predict with multiple-part
      const fd = new FormData();
      fd.append("inputs", http.file(dog_img));
      check(http.post(`${apiHost}/models/${model_name}/versions/1/upload/outputs`, fd.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs form-data cls response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs form-data cls contents`]: (r) =>
          r.json().output.classification_outputs.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs form-data cls contents.category`]: (r) =>
          r.json().output.classification_outputs[0].category === "match",
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs form-data cls response contents.score`]: (r) =>
          r.json().output.classification_outputs[0].score === 1,
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

  // Model Backend API: make inference
  {
    group("Model Backend API: Predict Model with detection model", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_DETECTION");
      fd_cls.append("content", http.file(det_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models/upload (multipart) det response Status": (r) =>
          r.status === 200,
          "POST /models/upload (multipart) task det response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models/upload (multipart) task det response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models/upload (multipart) task det response task": (r) =>
          r.json().Task === "TASK_DETECTION",
          "POST /models/upload (multipart) task det response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      let payload = JSON.stringify({
        "status": 2,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_ONLINE",
      });

      // Predict with url
      payload = JSON.stringify({
        "inputs": [{"image_url": "https://artifacts.instill.tech/dog.jpg"}],
      });
      check(http.post(`${apiHost}/models/${model_name}/versions/1/outputs`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs url det response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url det contents`]: (r) =>
          r.json().output.detection_output.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url det response category`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].category === "test",
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url det response score`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].score !== undefined,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url det response bounding_box`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].bounding_box !== undefined,
      });

      // Predict with base64
      payload = JSON.stringify({
        "inputs": [{"image_base64": base64_image,}]
      });
      check(http.post(`${apiHost}/models/${model_name}/versions/1/outputs`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 det response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 det contents`]: (r) =>
          r.json().output.detection_output.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 det response category`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].category === "test",
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 det response score`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].score !== undefined,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 det response bounding_box`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].bounding_box !== undefined,
      });

      // Predict with multiple-part
      const fd = new FormData();
      fd.append("inputs", http.file(dog_img));
      check(http.post(`${apiHost}/models/${model_name}/versions/1/upload/outputs`, fd.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/upload/outputs multiple-part det response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/upload/outputs multiple-part det contents`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/upload/outputs multiple-part det response category`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].category === "test",
          [`POST ${apiHost}/models/${model_name}/versions/1/upload/outputs multiple-part det response score`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].score !== undefined,
          [`POST ${apiHost}/models/${model_name}/versions/1/upload/outputs multiple-part det response bounding_box`]: (r) =>
          r.json().output.detection_output[0].bounding_box_objects[0].bounding_box !== undefined,
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

  // Model Backend API: make inference
  {
    group("Model Backend API: Predict Model with undefined task model", function () {
      let fd = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd.append("name", model_name);
      fd.append("description", randomString(20));
      fd.append("content", http.file(cls_model, "dummy-cls-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_UNSPECIFIED",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      let payload = JSON.stringify({
        "status": 2,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response description`]: (r) =>
          r.json().model_version.description !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model version status`]: (r) =>
          r.json().model_version.status === "STATUS_ONLINE",
      });

      // Predict with url
      payload = JSON.stringify({
        "inputs": [{"image_url": "https://artifacts.instill.tech/dog.jpg"}]
      });
      check(http.post(`${apiHost}/models/${model_name}/versions/1/outputs`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs url undefined response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url undefined outputs`]: (r) =>
          r.json().output.outputs.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url undefined parameters`]: (r) =>
          r.json().output.parameters !== undefined,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url undefined raw_output_contents`]: (r) =>
          r.json().output.raw_output_contents.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs url undefined raw_output_contents content`]: (r) =>
          r.json().output.raw_output_contents[0] !== undefined,
      });

      // Predict with base64
      payload = JSON.stringify({
        "inputs": [{"image_base64": base64_image,}]
      });
      check(http.post(`${apiHost}/models/${model_name}/versions/1/outputs`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 undefined response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 undefined outputs`]: (r) =>
          r.json().output.outputs.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 undefined parameters`]: (r) =>
          r.json().output.parameters !== undefined,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 undefined raw_output_contents`]: (r) =>
          r.json().output.raw_output_contents.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs base64 undefined raw_output_contents content`]: (r) =>
          r.json().output.raw_output_contents[0] !== undefined,
      });

      // Predict with multiple-part
      fd = new FormData();
      fd.append("inputs", http.file(dog_img));
      check(http.post(`${apiHost}/models/${model_name}/versions/1/upload/outputs`, fd.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd.boundary}`),
      }), {
        [`POST ${apiHost}/models/${model_name}/versions/1/outputs multipart undefined response Status`]: (r) =>
          r.status === 200,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs multipart undefined outputs`]: (r) =>
          r.json().output.outputs.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs multipart undefined parameters`]: (r) =>
          r.json().output.parameters !== undefined,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs multipart undefined raw_output_contents`]: (r) =>
          r.json().output.raw_output_contents.length === 1,
          [`POST ${apiHost}/models/${model_name}/versions/1/outputs multipart undefined raw_output_contents content`]: (r) =>
          r.json().output.raw_output_contents[0] !== undefined,
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

  // Model Backend API: Get model info
  {
    group("Model Backend API: Get model info", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_DETECTION");
      fd_cls.append("content", http.file(det_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models/upload (multipart) det response Status": (r) =>
          r.status === 200,
          "POST /models/upload (multipart) task det response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models/upload (multipart) task det response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models/upload (multipart) task det response task": (r) =>
          r.json().Task === "TASK_DETECTION",
          "POST /models/upload (multipart) task det response Versions": (r) =>
          r.json().Versions.length === 1,
      });
      check(http.get(`${apiHost}/models/${model_name}`, {
        headers: genHeader(`application/json`),
      }), {
        [`GET ${apiHost}/models/${model_name} response Status`]: (r) =>
          r.status === 200,
          [`GET ${apiHost}/models/${model_name} cv_task`]: (r) =>
          r.json().model.task === "TASK_DETECTION",
          [`GET ${apiHost}/models/${model_name} versions`]: (r) =>
          r.json().model.model_versions.length === 1,
          [`GET ${apiHost}/models/${model_name} version created_at`]: (r) =>
          r.json().model.model_versions[0].created_at !== undefined,
          [`GET ${apiHost}/models/${model_name} version updated_at`]: (r) =>
          r.json().model.model_versions[0].updated_at !== undefined,
          [`GET ${apiHost}/models/${model_name} version status`]: (r) =>
          r.json().model.model_versions[0].status === "STATUS_OFFLINE",
          [`GET ${apiHost}/models/${model_name} id`]: (r) =>
          r.json().model.id !== undefined,
          [`GET ${apiHost}/models/${model_name} full_Name`]: (r) =>
          r.json().model.full_name === `local-user/${model_name}`,
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

 // Model Backend API: Get model list
  {
    group("Model Backend API: Get model list", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_DETECTION");
      fd_cls.append("content", http.file(det_model, "dummy-det-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models/upload (multipart) det response Status": (r) =>
          r.status === 200,
          "POST /models/upload (multipart) task det response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models/upload (multipart) task det response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models/upload (multipart) task det response task": (r) =>
          r.json().Task === "TASK_DETECTION",
          "POST /models/upload (multipart) task det response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      check(http.get(`${apiHost}/models`, {
        headers: genHeader(`application/json`),
      }), {
        [`GET ${apiHost}/models response Status`]: (r) =>
          r.status === 200,
          [`GET ${apiHost}/models cv_task`]: (r) =>
          r.json().models[0].task !== undefined,
          [`GET ${apiHost}/models versions`]: (r) =>
          r.json().models[0].model_versions.length > 0,
          [`GET ${apiHost}/models version created_at`]: (r) =>
          r.json().models[0].model_versions[0].created_at !== undefined,
          [`GET ${apiHost}/models version updated_at`]: (r) =>
          r.json().models[0].model_versions[0].updated_at !== undefined,
          [`GET ${apiHost}/models version status`]: (r) =>
          r.json().models[0].model_versions[0].status !== undefined,
          [`GET ${apiHost}/models id`]: (r) =>
          r.json().models[0].id !== undefined,
          [`GET ${apiHost}/models full_Name`]: (r) =>
          r.json().models[0].full_name !== undefined,
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

  // Model Backend API: update model version description
  {
    group("Model Backend API: Update model version description", function () {
      let fd_cls = new FormData();
      let model_name = randomString(10)
      console.log("Create model ", model_name)
      fd_cls.append("name", model_name);
      fd_cls.append("description", randomString(20));
      fd_cls.append("task", "TASK_CLASSIFICATION");
      fd_cls.append("content", http.file(cls_model, "dummy-cls-model.zip"));
      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 1,
      });

      check(http.request("POST", `${apiHost}/models/upload`, fd_cls.body(), {
        headers: genHeader(`multipart/form-data; boundary=${fd_cls.boundary}`),
      }), {
        "POST /models (multipart) cls response Status": (r) =>
          r.status === 200, // TODO: update status to 201
          "POST /models (multipart) task cls response Name": (r) =>
          r.json().Name !== undefined,
          "POST /models (multipart) task cls response FullName": (r) =>
          r.json().FullName !== undefined,
          "POST /models (multipart) task cls response task": (r) =>
          r.json().Task === "TASK_CLASSIFICATION",
          "POST /models (multipart) task cls response Versions": (r) =>
          r.json().Versions.length === 2,
      });

      let new_description = randomString(20)
      let payload = JSON.stringify({
        "description": new_description,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/1`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response description`]: (r) =>
          r.json().model_version.description === new_description,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/1 online task cls response model version status`]: (r) =>
          r.json().model_version.status !== undefined,
      });

      let new_description2 = randomString(20)
      payload = JSON.stringify({
        "description": new_description2,
      });
      check(http.patch(`${apiHost}/models/${model_name}/versions/2`, payload, {
        headers: genHeader(`application/json`),
      }), {
        [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response status`]: (r) =>
          r.status === 200, // TODO: update status to 201
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response version`]: (r) =>
          r.json().model_version.version !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response model_id`]: (r) =>
          r.json().model_version.model_id !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response description`]: (r) =>
          r.json().model_version.description === new_description2,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response created_at`]: (r) =>
          r.json().model_version.created_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response updated_at`]: (r) =>
          r.json().model_version.updated_at !== undefined,
          [`PATCH ${apiHost}/models/${model_name}/versions/2 online task cls response model version status`]: (r) =>
          r.json().model_version.status !== undefined,
      });

      // clean up
      check(http.request("DELETE", `${apiHost}/models/${model_name}`, null, {
        headers: genHeader(`application/json`),
      }), {
        "DELETE clean up response Status": (r) =>
          r.status === 200 // TODO: update status to 204
      });

      // Triton unloading models takes time
      sleep(4)
    });
  }

  sleep(1);
}

export function teardown(data) {
  group("Model API: Delete all models created by this test", () => {
    let res = http
    .request("GET", `${apiHost}/models`, null, {
      headers: genHeader(
        "application/json"
      ),
    })
    for (const model of http
      .request("GET", `${apiHost}/models`, null, {
        headers: genHeader(
          "application/json"
        ),
      })
      .json("models")) {
      check(model, {
        "GET /clients response contents[*] id": (c) => c.id !== undefined,
      });
      check(
        http.request("DELETE", `${apiHost}/models/${model.name}`, null, {
          headers: genHeader("application/json"),
        }),
        {
          [`DELETE /models/${model.name} response status is 204`]: (r) =>
            r.status === 200, //TODO: update to 204
        }
      );
    }
  });
}
