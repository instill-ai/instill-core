
package bigqueryclient

import (
	"context"
	"cloud.google.com/go/bigquery"
)

// BigQueryClient defines the interface for the BigQuery client
type BigQueryClient interface {
	CreateTable(ctx context.Context, datasetID string, tableID string, schema bigquery.Schema) error
}

// MyBigQueryClient implements the BigQueryClient interface
type MyBigQueryClient struct {
	client *bigquery.Client
}

// CreateTable creates a new table in BigQuery
func (m *MyBigQueryClient) CreateTable(ctx context.Context, datasetID string, tableID string, schema bigquery.Schema) error {
	table := m.client.Dataset(datasetID).Table(tableID)
	return table.Create(ctx, &bigquery.TableMetadata{Schema: schema})
}
