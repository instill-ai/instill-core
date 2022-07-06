# Data Connector

_data connector_ is a general term to represent data source and data destination of a pipeline.

## Stage of Connectors

Instill AI provides connectors for data integration, and we propose a `Stage` to users for understanding what current status are of the connectors

**Alpha**: This connector is not fully tested

**Beta**: The connector is well tested and is expected to work a majority of the time

**Generally available**: Instill AI approves this connector

> **Note**
> We will continue adding new connectors to VDP. If you want to make a request, please feel free to open an issue and describe your use case in details.

### Data Sources

| Connector | Stage | Description |
| :--- | :--- | --- |
| HTTP | Alpha | Users ingest data to HTTP endpoint directly |
| gRPC | Alpha | Users ingest data to gRPC endpoint directly |

### Data Destinations

| Connector | Stage | Description |
| :--- | :--- | --- |
| HTTP | Alpha | Paired with the HTTP source. When the data has proceeded, the data is sent back to users directly depending on the trigger endpoint |
| gRPC | Alpha | Paired with the gRPC source. When the data has proceeded, the data is sent back to users directly depending on the trigger endpoint |
