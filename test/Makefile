.DEFAULT_GOAL:=test-all

.EXPORT_ALL_VARIABLES:

.PHONY: prepare-k6
prepare-k6:
	@go version
	@go install go.k6.io/xk6/cmd/xk6@latest
	@xk6 build --with github.com/szkiba/xk6-jose@latest

.PHONY: cleanup-k6
cleanup-k6:
	@rm k6

.PHONY: pipeline-mobilenetv2
pipeline-mobilenetv2:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) -e TARGET=$(TARGET) ./pipeline/pipeline-mobilenetv2.js

.PHONY: pipeline-yolov7
pipeline-yolov7:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-yolov7.js --no-usage-report

.PHONY: pipeline-instance-segmentation
pipeline-instance-segmentation:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-instance-segmentation.js --no-usage-report

.PHONY: pipeline-semantic-segmentation
pipeline-semantic-segmentation:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-semantic-segmentation.js --no-usage-report

.PHONY: pipeline-keypoint
pipeline-keypoint:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-keypoint.js --no-usage-report

.PHONY: pipeline-ocr
pipeline-ocr:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-ocr.js --no-usage-report

.PHONY: pipeline-text-generation
pipeline-text-generation:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-gpt2.js --no-usage-report

.PHONY: pipeline-text-to-image
pipeline-text-to-image:
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e HOST=$(HOST) ./pipeline/pipeline-diffusion.js --no-usage-report

test-all: pipeline-mobilenetv2 pipeline-yolov7 pipeline-instance-segmentation pipeline-semantic-segmentation pipeline-keypoint pipeline-ocr
.PHONE: test-all
