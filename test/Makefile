## Supported env variables
## 	MODE: accept values 'demo', 'localhost', testing pipelines on demo VDP or localhost VDP
## 	TEST_CPU_ONLY: a boolean flag to indicate whether to test model on CPU only, used for testing on a CPU-only machine
##	TEST_GPU_ONLY: a boolean flag to indicate whether to test model on GPU only
##	TARGET: accept values 'm1', used for testing on OSX M1

## Some test script examples
##	for testing on OSX m1
## make test-no-large-models MODE=localhost TEST_CPU_ONLY=true TARGET=m1
##	for testing on device with Nvidia GPU
## make test-all MODE=localhost

.DEFAULT_GOAL:=test-all

.EXPORT_ALL_VARIABLES:

.PHONY: prepare-k6
prepare-k6:		## Prepare K6
	@go version
	@go install go.k6.io/xk6/cmd/xk6@latest
	@xk6 build --with github.com/szkiba/xk6-jose@latest

.PHONY: cleanup-k6
cleanup-k6:		## Cleanup K6
	@rm k6

.PHONY: pipeline-mobilenetv2
pipeline-mobilenetv2:		## Test MobileNetV2 pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} -e TARGET=$(TARGET) ./pipeline/pipeline-mobilenetv2.js --no-usage-report

.PHONY: pipeline-yolov7
pipeline-yolov7:		## Test YOLOv7 pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} ./pipeline/pipeline-yolov7.js --no-usage-report

.PHONY: pipeline-instance-segmentation
pipeline-instance-segmentation:		## Test Instance segmentation pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} ./pipeline/pipeline-instance-segmentation.js --no-usage-report

.PHONY: pipeline-semantic-segmentation
pipeline-semantic-segmentation:		## Test Semantic Segmentation pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} ./pipeline/pipeline-semantic-segmentation.js --no-usage-report

.PHONY: pipeline-keypoint
pipeline-keypoint:		## Test Keypoint Detection pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} ./pipeline/pipeline-keypoint.js --no-usage-report

.PHONY: pipeline-ocr
pipeline-ocr:		## Test OCR pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} ./pipeline/pipeline-ocr.js --no-usage-report

.PHONY: pipeline-text-generation
pipeline-text-generation:	## Test Text Generation pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) -e TEST_CPU_ONLY=${TEST_CPU_ONLY} -e TEST_GPU_ONLY=${TEST_GPU_ONLY} ./pipeline/pipeline-text-generation.js --no-usage-report

.PHONY: pipeline-text-to-image
pipeline-text-to-image:		## Test Text to Image pipeline
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run -e MODE=$(MODE) ./pipeline/pipeline-text-to-image.js --no-usage-report

.PHONY: test-no-large-models	## Test all pipeline without large models 
test-no-large-models: prepare-k6 pipeline-mobilenetv2 pipeline-yolov7 pipeline-instance-segmentation pipeline-semantic-segmentation pipeline-keypoint pipeline-ocr cleanup-k6

.PHONY: test-all	## Test all pipeline 
test-all: prepare-k6 pipeline-mobilenetv2 pipeline-yolov7 pipeline-instance-segmentation pipeline-semantic-segmentation pipeline-keypoint pipeline-ocr pipeline-text-generation pipeline-text-to-image cleanup-k6

.PHONY: help
help:       	## Show this help
	@echo "\nTest models"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
