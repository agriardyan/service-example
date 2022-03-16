SERVICE_NAME=service-example
BUILD_VERSION=$(shell cat version.txt)
COMMIT_HASH=$(shell git rev-parse HEAD)
BUILD_DATE=$(shell LANG=en_us_88591; date)

.PHONY: help
help: ## - Show help message
	@printf "usage: make [target]\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:	## - Build the smallest and secured golang docker image based on scratch
	@printf "Build the smallest and secured golang docker image based on scratch\n"
	@echo $(SERVICE_NAME):$(BUILD_VERSION)
	@echo $(BUILD_DATE)
	@export DOCKER_CONTENT_TRUST=1 && docker build --build-arg buildVersion=$(BUILD_VERSION) --build-arg commitHash=$(COMMIT_HASH) --build-arg buildDate="$(BUILD_DATE)" -f Dockerfile --tag="$(SERVICE_NAME):$(BUILD_VERSION)" . && docker image prune --filter label=stage=builder -f

.PHONY: clean-build
clean-build: ## Clean after build
	@printf "Clean after build"
	docker image prune --filter label=stage=builder -f