package temporal

import (
	"bytes"
	"context"
	"encoding/gob"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/instill-ai/protogen-go/pipeline"
	"github.com/instill-ai/vdp/configs"
	"github.com/instill-ai/vdp/internal/cache"
	"github.com/instill-ai/vdp/pkg/models"
	"go.temporal.io/sdk/activity"
)

type PipelineActivities struct {
}

func (a *PipelineActivities) DataSourceActivity(ctx context.Context, input []string) (string, error) {
	log := activity.GetLogger(ctx)

	name := activity.GetInfo(ctx).ActivityType.Name
	log.Info(fmt.Sprintf("Run %s with input %v \n", name, input))
	return "Result_" + name, nil
}

func (a *PipelineActivities) VisualDataOperatorActivity(ctx context.Context, input []string) (string, error) {
	log := activity.GetLogger(ctx)

	name := activity.GetInfo(ctx).ActivityType.Name
	log.Info(fmt.Sprintf("Run %s with input %v \n", name, input))

	modelId := input[0]
	version := input[1]
	requestId := input[2]

	var result []byte
	var err error
	// Fetch serialized data from Redis
	if result, err = cache.Redis.Get(context.Background(), requestId).Bytes(); err != nil {
		log.Error(err.Error())
	}

	// Deserialized data to sturct
	var httpBodyCache = models.VDOHttpBodyCache{}
	gob.Register(pipeline.TriggerPipelineRequest{})
	dec := gob.NewDecoder(bytes.NewBuffer(result))
	if err := dec.Decode(&httpBodyCache); err != nil {
		log.Error(err.Error())
	}

	vdoEndpoint := fmt.Sprintf("%s://%s:%d/%s",
		configs.Config.VDO.Scheme,
		configs.Config.VDO.Host,
		configs.Config.VDO.Port,
		fmt.Sprintf(configs.Config.VDO.Path, modelId, version))
	c := &http.Client{}

	var resp *http.Response

	contentType := strings.Split(httpBodyCache.ContentType, ";")[0]
	switch contentType {
	case "application/json":
		var httpBodyJSON []byte

		// Convert struct to JSON object
		if httpBodyJSON, err = json.Marshal(httpBodyCache.Body); err != nil {
		}

		if resp, err = c.Post(vdoEndpoint, "application/json", bytes.NewBuffer(httpBodyJSON)); err != nil {
			log.Error(err.Error())
		}
		defer resp.Body.Close()
	case "multipart/form-data":

		req, _ := http.NewRequest("POST", vdoEndpoint, bytes.NewBuffer(httpBodyCache.Body.([]byte)))
		req.Header.Add("Content-Type", httpBodyCache.ContentType)

		if resp, err = c.Do(req); err != nil {
		}
	}

	var bodyBytes []byte
	if resp.StatusCode == http.StatusOK {
		bodyBytes, err = ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Error(err.Error())
		}
		bodyString := string(bodyBytes)
		log.Debug(bodyString)
	}

	return string(bodyBytes), nil
}

func (a *PipelineActivities) LogicOperatorAddActivity(ctx context.Context, input []string) (string, error) {
	log := activity.GetLogger(ctx)

	name := activity.GetInfo(ctx).ActivityType.Name
	log.Info(fmt.Sprintf("Run %s with input %v \n", name, input))
	return "Result_" + name, nil
}

func (a *PipelineActivities) LogicOperatorSubActivity(ctx context.Context, input []string) (string, error) {
	log := activity.GetLogger(ctx)

	name := activity.GetInfo(ctx).ActivityType.Name
	log.Info(fmt.Sprintf("Run %s with input %v \n", name, input))
	return "Result_" + name, nil
}

func (a *PipelineActivities) LogicOperatorEqualActivity(ctx context.Context, input []string) (string, error) {
	log := activity.GetLogger(ctx)

	name := activity.GetInfo(ctx).ActivityType.Name
	log.Info(fmt.Sprintf("Run %s with input %v \n", name, input))
	return "Result_" + name, nil
}

func (a *PipelineActivities) DataDestinationActivity(ctx context.Context, input []string) (string, error) {
	log := activity.GetLogger(ctx)

	name := activity.GetInfo(ctx).ActivityType.Name
	log.Info(fmt.Sprintf("Run %s with input %v \n", name, input))
	return "Result_" + name, nil
}
