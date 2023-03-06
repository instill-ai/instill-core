# Build a _Cow Counter_ dashboard demo

This demo is to showcase using [VDP](https://github.com/instill-ai/vdp) and [Metabase](https://www.metabase.com) to build a _Cow Counter_ dashboard based on a drone video at a cattle farm.

## Preparation

#### Run VDP locally

```bash
$ git clone https://github.com/instill-ai/vdp.git && cd vdp
$ make all
```
The VDP Console is at `http://localhost:3000/`

#### Run Metabase locally

```bash
$ docker pull metabase/metabase:latest
$ docker run -d -p 3100:3000 --name metabase metabase/metabase
```

Once Metabase startup completes, you can access it at `http://localhost:3100`.

**Caveats**
If the above official Metabase docker image doesn't work on M1(apple silicon) mac, try to build an image with the `Dockerfile-metabase-m1`

```bash
$ docker build -f Dockerfile-metabase-m1 -t metabase/metabase-m1 .
$ docker run -d -p 3100:3000 --name metabase metabase/metabase-m1
```

## How to run the demo

> **Note**
> The downloaded 1-minute video used in the demo is sampled from a public video `cows dornick.mp4` from [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/YFDJRO).

**Step 1**: Create an ASYNC pipeline `detection` by following the [tutorial](https://www.instill.tech/tutorials/vdp-cow-counter)
   - data source: HTTP
   - model: [YOLOv7](https://github.com/instill-ai/model-yolov7-dvc)
   - data destination: Postgres database `tutorial`

**Step 2**: Run the following command to trigger the `detection` pipeline to process `cow_dornick.mp4` video into structured data

```bash
# Install dependencies
$ pip install -r requirements.txt

# Run the demo
#   --api-gateway-url=< VDP API base URL >
#   --pipeline-id=< pipeline ID >
#   --pq-host=< database host >
#   --pq-port=< database port >
#   --pq-database=< database name >
#   --pq-username=< database username >
#   --pq-password=< database password >
#   --output-filename=< output image directory >
#   --framerate=< frame rate of the video file >
#   --skip-draw
$ python main.py --api-gateway-url=http://localhost:8080 --pipeline-id=detection --pq-host=< database host > --pq-port=< database port > --pq-database=tutorial --pq-username=< database username > --pq-password=< database password > --skip-draw
```

**Step 3**: Add the Postgres database `tutorial` used by the ASYNC pipeline to Metabase and start exploring the structured data.

You can use the following SQL query to convert the raw detections into multiple records and build a _Cow Counter_ dashboard
```sql
-- Cow counter
SELECT "public"."_airbyte_raw_vdp"."_airbyte_ab_id" AS "id", "public"."_airbyte_raw_vdp"."_airbyte_data"->'index' AS "index", "public"."_airbyte_raw_vdp"."_airbyte_emitted_at" AS "processed_at", ceil(x.score) AS "count", x.category
FROM "public"."_airbyte_raw_vdp" CROSS JOIN LATERAL jsonb_to_recordset("public"."_airbyte_raw_vdp"."_airbyte_data"->'detection'->'objects') AS x(score numeric, category text)
WHERE x.category = 'cow'
ORDER BY "processed_at" ASC
LIMIT 1048575
```

## Shut down VDP

To shut down all running VDP services:
```
$ make down
```
