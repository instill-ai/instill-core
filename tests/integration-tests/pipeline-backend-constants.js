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
