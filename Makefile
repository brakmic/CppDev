IMAGE ?= brakmic/cppdev
TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64
EXTRA_TOOLS ?= false
DEVCONTAINER_TAG ?= devcontainer

.PHONY: help build build-extra devcontainer smoke test buildx publish

help:
	@printf '%s\n' \
		'build          Build the base image for the local architecture' \
		'build-extra    Build the base image with optional tooling' \
		'devcontainer   Build the dev container image on top of the base image' \
		'smoke          Run the smoke test against $(IMAGE):$(TAG)' \
		'buildx         Build a multi-architecture image without pushing' \
		'publish        Build and push a multi-architecture image'

build:
	docker build --build-arg INSTALL_EXTRA_TOOLS=$(EXTRA_TOOLS) -t $(IMAGE):$(TAG) .

build-extra:
	$(MAKE) build EXTRA_TOOLS=true

devcontainer:
	docker build -f devcontainer.Dockerfile --build-arg BASE_IMAGE=$(IMAGE):$(TAG) -t $(IMAGE):$(DEVCONTAINER_TAG) .

smoke:
	bash scripts/smoke-test.sh $(IMAGE):$(TAG)

test: smoke

buildx:
	docker buildx build --platform $(PLATFORMS) --build-arg INSTALL_EXTRA_TOOLS=$(EXTRA_TOOLS) -t $(IMAGE):$(TAG) .

publish:
	docker buildx build --platform $(PLATFORMS) --push -t $(IMAGE):$(TAG) .
