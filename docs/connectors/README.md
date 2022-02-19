# Data Connectors

There are two kinds of triggering mechanisms: synchronous (`SYNC`) and asynchronous (`ASYNC`). We use the diagrams below to show the difference. For the `SYNC` trigger, the result is sent back to the user once the data is processed. For the `ASYNC` trigger, the user only receives an acknowledged response. Once the data is processed, the result is sent to the data destination.

### SYNC
<p align="center">
<img src="docs/mermaid/sync.svg" alt="Synchronous triggering mechanism" />
</p>

### ASYNC
<p align="center">
<img src="docs/mermaid/async.svg" alt="Asynchronous triggering mechanism" />
</p>

## Stage of Connectors

Instill AI provides connectors for data integration, and we propose a `Stage` to users for understanding what current status are of the connectors

**Release**: Instill AI approves this connector

**Beta**: The connector is well tested and is expected to work a majority of the time

**Alpha**: This connector is not fully tested

### Data Sources

| Connector | Stage | Description |
| :--- | :--- | --- |
| Direct | Alpha | Users ingest data to HTTP/gRPC endpoint directly |

### Data Destinations

| Connector | Stage | Description |
| :--- | :--- | --- |
| Direct | Alpha | When the data has proceeded, the data is sent back to users directly depending on the trigger endpoint |
