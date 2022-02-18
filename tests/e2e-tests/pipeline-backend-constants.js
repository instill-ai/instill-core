export const yoloDetectionModel = {
  name: "yolov4",
  version: 1,
};

export const detectionRecipe = {
  recipe: {
    source: {
      type: "http",
    },
    model: [yoloDetectionModel],
    destination: {
      type: "http",
    },
  },
};
