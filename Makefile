
# The repository name, based on the directory name.
REPO = $(shell basename $(shell git rev-parse --show-toplevel))

# The org used in a few places (GitHub, Buildkite, etc).
ORG ?= jmpa-io

#
# Variables.
#

# The default goal run with just 'make'.
.DEFAULT_GOAL := help

# The git commit hash.
COMMIT ?= $(shell git describe --tags --always)

#
# Dependencies.
#

DEPENDENCIES ?= \
	awk \
	column

# Determines if there are any missing dependencies.
MISSING := \
  $(strip \
    $(foreach binary,$(DEPENDENCIES), \
      $(if $(shell command -v $(binary) 2>/dev/null),,$(binary)) \
    ) \
  )

# Stops the Makefile execution if there are any missing dependencies.
$(if $(MISSING),$(error Please install: $(MISSING)))

#
# Docker.
#

TAGS ?= $(COMMIT) latest

REGISTRY ?= packages.buildkite.com/$(ORG)/$(REPO)
REGISTRY_IMAGE := $(REGISTRY)/$(REPO):$(COMMIT)

build-image: ## Builds the root Dockerfile in this repository. 
build-image: Dockerfile
	docker build \
		$(patsubst %,-t $(REPO):%,$(TAGS)) \
		-f $< .

tag-image-with-registry: # Tags the root Docker image with the Docker registry path.
tag-image-with-registry: build-image
	docker tag $(REPO):$(COMMIT) $(REGISTRY_IMAGE)

push-image: ## Pushes the root Docker image, built from the root Dockerfile, to the Docker registry.
push-image: tag-image-with-registry
	docker push $(REGISTRY_IMAGE)

pull-image: ## Pulls the root Docker image from the Docker registry.
pull-image: 
	docker pull $(REGISTRY_IMAGE)

docker: ## Runs this project locally inside a Docker container.
docker: build-image
	docker run -it \
		-v "$(PWD):/app" \
		-w "/app" \
		"$(REPO):$(COMMIT)" bash 

#
# Utility.
#

clean: ## Resets this repository back to state it was when first cloned.
clean:
	@rm -rf dist

help: ## Prints this help page.
help:
	@echo "Available targets:"
	@awk_script='\
		/^[a-zA-Z\-\\_0-9%\/$$]+:/ { \
			target = $$1; \
			gsub("\\$$1", "%", target); \
			nb = sub(/^## /, "", helpMsg); \
			if (nb == 0) { \
				helpMsg = $$0; \
				nb = sub(/^[^:]*:.* ## /, "", helpMsg); \
			} \
			if (nb && !match(helpMsg, /^List/)) print "\033[33m" target "\033[0m" helpMsg; \
		} \
		{ helpMsg = $$0 } \
	'; \
	awk "$$awk_script" $(MAKEFILE_LIST) | column -ts:

PHONY += clean help

#
# .PHONY
#

.PHONY: $(PHONY)
