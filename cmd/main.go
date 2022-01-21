package main

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/bochengyang/zapadapter"
	"github.com/instill-ai/visual-data-pipeline/configs"
	"github.com/instill-ai/visual-data-pipeline/internal/cache"
	"github.com/instill-ai/visual-data-pipeline/internal/health"
	"github.com/instill-ai/visual-data-pipeline/pkg/temporal"
	"go.temporal.io/api/workflowservice/v1"
	"go.temporal.io/sdk/client"
	"go.temporal.io/sdk/worker"
	"go.uber.org/zap"
)

func namespaceChecking() {

	logger, _ := zap.NewProduction()

	nc, err := client.NewNamespaceClient(client.Options{
		HostPort: configs.Config.Temporal.ClientOptions.HostPort,
	})

	if err != nil {
		panic(err)
	}

	defer nc.Close()

	resp, err := nc.Describe(context.Background(), configs.Config.Temporal.ClientOptions.Namespace)

	createNamespace := false

	if err != nil {
		expErrStr := fmt.Sprintf("Namespace %s does not exist.", configs.Config.Temporal.ClientOptions.Namespace)
		if expErrStr == err.Error() {
			createNamespace = true
		} else {
			panic(err)
		}
	} else {
		if resp != nil {
			logger.Info(fmt.Sprintf("Namespace exists: %+v\n", resp))
		}
	}

	retentionPeriod := time.Duration(configs.Config.Temporal.NamespaceOptions.Retentionhour) * time.Hour
	if createNamespace {
		err := nc.Register(context.Background(), &workflowservice.RegisterNamespaceRequest{
			Namespace:                        configs.Config.Temporal.ClientOptions.Namespace,
			Description:                      "For Instill Pipeline",
			WorkflowExecutionRetentionPeriod: &retentionPeriod,
		})
		if err != nil {
			panic(err)
		}
		logger.Info(fmt.Sprintf("Successfully create namespace %s\n", configs.Config.Temporal.ClientOptions.Namespace))
	}
}

func main() {

	logger, _ := zap.NewProduction()

	if err := configs.Init(); err != nil {
		logger.Fatal(err.Error())
	}

	cache.Init()
	defer cache.Close()

	namespaceChecking()

	clientOpts := configs.Config.Temporal.ClientOptions
	clientOpts.Logger = zapadapter.NewZapAdapter(logger)

	// The client and worker are heavyweight objects that should be created once per process.
	c, err := client.NewClient(clientOpts)
	if err != nil {
		logger.Fatal(fmt.Sprintf("Unable to create client: %v", err))
	}
	defer c.Close()

	w := worker.New(c, temporal.TaskQueueName, worker.Options{})

	w.RegisterWorkflow(temporal.PipelineWorkflow)
	w.RegisterActivity(&temporal.PipelineActivities{})

	http.HandleFunc("/__readiness", health.ReadinessHandler)
	http.HandleFunc("/__liveness", health.LivenessHandler)
	go http.ListenAndServe(":5000", nil)

	err = w.Run(worker.InterruptCh())
	if err != nil {
		logger.Fatal(fmt.Sprintf("Unable to start worker: %v", err))
	}
}
