## Onboarding
You should see the onboarding page for the first time using the console. Please enter your email to proceed.

![Onboarding page of the VDP console](assets/onboarding.png)

## Add a HTTP source

After onboarding, you will be redirected to the `Pipeline` tab on the left sidebar, where you can build your first VDP pipeline by clicking `Create your first pipeline` and forever change the way you approach visual data processing workflow development.

![Pipeline list page of the VDP console](assets/pipeline-list-empty.png)

In this tutorial you'll build your first **Sync** pipeline and trigger the pipeline to process some images. You can follow the tutorial via the `Pipeline` tab or navigate to the `Data source` tab.

A HTTP source accepts HTTP requests with image payloads to be processed by a pipeline. To set it up, just choose `HTTP` from the drop-down list below. 

![Add a HTTP source to create a pipeline in the VDP console](assets/add-a-source-http.png)

## Import a model from GitHub repo

To process images, here we import a model from our public GitHub repo [instill-ai/model-mobilenetv2](https://github.com/instill-ai/model-mobilenetv2). To set it up, just follow the instructions on the UI and click `Setup new model`:
1. Pick a name for your model, this will be the unique identifier of this model; 
2. Select `GitHub` from the drop-down list;
3. Fill the GitHub repository `instill-ai/model-mobilenetv2`.

![Import a model from a GitHub repo via VDP console](assets/add-a-model.png)

VDP will fetch all the releases of the GitHub repository. Each release is converted into one model instance. You can think of an model instance as a snapshot of the imported model. The imported model could have multiple model instances, each of which is named using the release tag.

## Deploy a model instance

Once the model is imported, we pick one from all the model instances, and click `deploy` to deploy it online.

![Deploy a model instance via VDP console](assets/deploy-a-model-instance.png)


## Add a HTTP destination

Just click `Next`. Since we are building a `Sync` pipeline, the HTTP destination is automatically paired with the HTTP source.

![Add a HTTP destination to create a pipeline in the VDP console](assets/add-a-destination-http.png)


## Set up your first pipeline

Almost done! Just give your pipeline a unique id and an optional description, and click `Set up pipeline`.

![Set up a pipeline in the VDP console](assets/set-up-a-pipeline.png)

## Trigger your pipeline for the first time

Now that the `classification` pipeline is automatically activated, you can make a request to trigger the pipeline to process **multiple** images within a batch:

```bash
curl -X POST \
--data-raw '{
  "inputs": [
    {
      "image_url": "https://artifacts.instill.tech/dog.jpg"
    },
    {
      "image_url": "https://images.pexels.com/photos/66898/elephant-cub-tsavo-kenya-66898.jpeg"
    }
  ]
}' \
http://localhost:8081/v1alpha/pipelines/classification:trigger
```
In which `8081` is the port of the local pipeline backend.


A HTTP response will return
```bash
{
  "output": {
    "classification_outputs": [
      {
        "category": "golden retriever",
        "score": 0.896806
      },
      {
        "category": "African elephant",
        "score": 0.861324
      }
    ]
  }
}
```

Besides using remote image url `image_url` as payload, you can send Base64-encoded images with `image_base64`

```bash
curl -X POST \
--data-raw '{
  "inputs": [
    {
      "image_base64": "/9j/4AAQSk...D/2Q=="
    },
    ...
  ]
}' \
http://localhost:8081/v1alpha/pipelines/classification:trigger
```

or send a multipart request

```
curl -X POST \
--form 'file=@"dog.jpg"' \
--form 'file=@"elephant.jpg"' \
http://localhost:8081/v1alpha/pipelines/classification:trigger-multipart
```

## 🙌 That's it!

This tutorial only shows the tip of what VDP is capable of and is just the beginning of your VDP journey.

We are actively supporting more connectors and model definitions. If you have any questions, please reach out to us on [Discord community](https://discord.gg/sevxWsqpGh). We're still in alpha, so if you see any bugs, please help create an issue on our [GitHub](https://github.com/instill-ai/vdp).