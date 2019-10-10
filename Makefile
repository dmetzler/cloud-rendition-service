STACK_NAME ?= cloud-rendition-service
DEPLOYMENT_BUCKET ?= my-deployment-bucket
IMAGE_BUCKET ?= image-resize

DOCKER=docker
CURRENT_DIR=$(shell pwd)

SRC_DIR=lambda
DIST_DIR=dist


_FUNCTIONS=origin-response-function viewer-request-function
FUNCTIONS=$(patsubst %,$(SRC_DIR)/%/node_modules,$(_FUNCTIONS))
DISTS=$(patsubst %,$(DIST_DIR)/%.zip,$(_FUNCTIONS))




all: build

lambda/origin-response-function/node_modules:
	$(DOCKER) run --rm --volume $(CURRENT_DIR)/lambda/origin-response-function:/build amazonlinux:nodejs /bin/bash -c "source ~/.bashrc; npm init -f -y; npm install sharp --save; npm install querystring --save; npm install --only=prod"

lambda/viewer-request-function/node_modules:
	$(DOCKER) run --rm --volume $(CURRENT_DIR)/lambda/viewer-request-function:/build amazonlinux:nodejs /bin/bash -c "source ~/.bashrc; npm init -f -y; npm install querystring --save; npm install --only=prod"


$(DIST_DIR)/%.zip: lambda/% lambda/%/node_modules
	mkdir -p $(DIST_DIR) && cd $< && zip -FS -q -r ../../$@ * && cd ../..


build: $(DISTS)


deploy: $(DISTS)
	mkdir -p target
	for distfile in $^; do \
		aws s3 cp dist/$${distfile} s3://$(DEPLOYMENT_BUCKET); \
	done
	aws cloudformation deploy --template-file template.yaml \
	                          --stack-name=$(STACK_NAME) \
	                          --capabilities CAPABILITY_IAM \
	                          --parameter-overrides BucketNamePrefix=$(IMAGE_BUCKET) \
	                                                LambdaBucket=$(DEPLOYMENT_BUCKET)
	aws cloudformation describe-stacks --stack-name $(STACK_NAME)

.PHONY: docker
docker:
	$(DOCKER) build --tag amazonlinux:nodejs .

.PHONY: clean
clean:
	rm -rf dist
	rm -rf lambda/origin-response-function/node_modules
	rm -rf lambda/viewer-request-function/node_modules
