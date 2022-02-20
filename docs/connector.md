# Data Connector

_data connector_ is a general term to represent data source and data destination of a pipeline.

## Stage of Connectors

Instill AI provides connectors for data integration, and we propose a `Stage` to users for understanding what current status are of the connectors

**Release**: Instill AI approves this connector

**Beta**: The connector is well tested and is expected to work a majority of the time

**Alpha**: This connector is not fully tested

 We will continue adding new connectors to VDP. If you want to make a request, please feel free to open an issue and describe your use case in details.

### Data Sources

| Connector | Stage | Description |
| :--- | :--- | --- |
| Direct | Alpha | Users ingest data to HTTP/gRPC endpoint directly |

### Data Destinations

| Connector | Stage | Description |
| :--- | :--- | --- |
| Direct | Alpha | When the data has proceeded, the data is sent back to users directly depending on the trigger endpoint |
