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
    models: [detectionModel],
    destination: {
      type: "Direct",
    },
  },
};

export const triggerPipelineJSONUrl = {
  inputs: [
    {
      imageUrl: "https://artifacts.instill.tech/dog.jpg",
    },
  ],
};

export const triggerPipelineJSONBase64 = {
  inputs: [
    {
      imageBase64: encoding.b64encode(dogImg, "b"),
    },
  ],
};
