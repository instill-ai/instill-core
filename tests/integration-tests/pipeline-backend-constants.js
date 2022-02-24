import encoding from "k6/encoding";

export const dogImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/tests/integration-tests/data/dog.jpg`, "b");

export const detectionModel = {
  name: "dummy-det",
  version: 1,
};

export const detectionRecipe = {
  recipe: {
    source: {
      type: "Direct",
    },
    model: [detectionModel],
    destination: {
      type: "Direct",
    },
  },
};

export const triggerPipelineJSONUrl = {
  contents: [
    {
      url: "https://artifacts.instill.tech/dog.jpg",
    },
  ],
};

export const triggerPipelineJSONBase64 = {
  contents: [
    {
      base64: encoding.b64encode(dogImg, "b"),
    },
  ],
};
