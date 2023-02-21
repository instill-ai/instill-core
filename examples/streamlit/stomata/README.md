# Stomata Instance Segmentation demo

This demo is to showcase using [VDP](https://github.com/instill-ai/vdp) to quickly set up a [Instance Segmentation](https://github.com/instill-ai/model-stomata-instance-segmentation-dvc) pipeline for identifying stomata.
It also uses [Streamlit](https://streamlit.io) to show the stomata segmentation results and calculated statistics by triggering the VDP pipeline.

## Preparation
Run VDP locally

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
$ make all
```

If this is your first time setting up VDP, access the Console (http://localhost:3000) and you should see the onboarding page. Please enter your email and you are all set!

After onboarding, you will be redirected to the **Pipeline** page on the left sidebar, where you can build your first VDP pipeline by clicking **Set up your first pipeline** and forever change the way you approach unstructured data processing workflow development.

#### Create a SYNC pipeline `stomata`

**Step 1: Add a HTTP source**
A HTTP source accepts HTTP requests with image payloads to be processed by a pipeline.

To set it up,

1. click the **Pipeline mode** ▾ drop-down and choose `Sync`,
2. click the **Source type** ▾ drop-down and choose `HTTP`, and
3. click **Next**.

**Step 2: Import a model from GitHub**

To process images, here we import a model from our public GitHub repo [instill-ai/model-stomata-instance-segmentation-dvc](https://github.com/instill-ai/model-stomata-instance-segmentation-dvc).

To set it up,

1. give your model a unique ID `stomata-instance-segmentation`,
2. [optional] add description,
3. click the **Model source** ▾ drop-down and choose `GitHub`,
4. fill in the GitHub repository URL `instill-ai/model-stomata-instance-segmentation-dvc`, and
5. click **Set up**.

VDP will fetch all the releases of the GitHub repository. Each release is converted into one model instance, using the release tag as the corresponding model instance ID.

**Step 3: Deploy a model instance of the imported model**

Once the model is imported,

1. click the **Model instances** ▾ drop-down,
2. pick one model instance, and
3. click **Deploy** to put it online.

**Step 4: Add a HTTP destination**

Since we are building a `SYNC` pipeline, the HTTP destination is automatically paired with the HTTP source.

Just click **Next**.

**Step 5: Set up the pipeline**

Almost done! Just

1. give your pipeline a unique ID `stomata`,
2. [optional] add description, and
3. click **Set up**.

Now you should see the newly created SYNC pipeline `stomata` on the Pipeline page 🎉

## How to run the demo
Run the following command
```bash
# Install dependencies
$ pip install -r requirements.txt

# Run the demo
#   --demo-url=< demo URL >
#   --pipeline-backend-base-url=< pipeline backend base URL >
#   --pipeline-id=< Stomata pipeline ID >
$ streamlit run main.py -- --pipeline-backend-base-url=http://localhost:8080 --pipeline-id=stomata
```

Now go to `http://localhost:8501/` 🎉


## Shut down VDP

To shut down all running services:
```
$ make down
```

## Deploy the demo using Docker

Build a Docker image
```bash
$ docker build -t streamlit-stomata .
```
Run the Docker container and connect to VDP
```bash
$ docker run --rm --name streamlit-stomata -p 8501:8501 --network instill-network streamlit-stomata -- --pipeline-backend-base-url=http://api-gateway:8080 --pipeline-id=stomata

You can now view your Streamlit app in your browser.

  URL: http://0.0.0.0:8501

```

