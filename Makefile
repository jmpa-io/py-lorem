
# The repository name, based on the directory name.
REPO = $(shell basename $(shell git rev-parse --show-toplevel))

# The org consistently used in various places (GitHub, Buildkite, etc).
ORG ?= jmpa-io

# The default goal run with just 'make'.
.DEFAULT_GOAL := help

#
# Variables.
#

# The git commit hash.
COMMIT ?= $(shell git describe --tags --always)

# The tags added to a Docker image built from this Makefile.
DOCKER_TAGS ?= $(COMMIT) latest

# The URL of the Docker registry used to store built Docker images.
DOCKER_REGISTRY ?= packages.buildkite.com/$(ORG)/$(REPO)

# An easy-to-reference URI of the Docker image stored in / pulled from the Docker registry.
DOCKER_REGISTRY_IMAGE := $(DOCKER_REGISTRY)/$(REPO):$(COMMIT)

#
# Dependencies.
#

DEPENDENCIES ?= \
	awk \
	column \
	python

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
# Targets.
#

dist: # Creates the dist output directory.
dist:
	@mkdir dist

lint: ## Lints everything.
lint: bin/10-lint.sh
	$<

generate-sentence: ## Generates 'dist/sentence.txt'.
generate-sentence: dist/sentence.txt
dist/sentence.txt: dist
dist/sentence.txt: bin/20-generate-sentence.py
	python $<

generate-paragraph: ## Generates 'dist/paragraph.txt'.
generate-paragraph: dist/paragraph.txt
dist/paragraph.txt: dist
dist/paragraph.txt: bin/30-generate-paragraph.py
	python $<

PHONY += generate-sentence \
		 generate-paragraph \
		 dist/sentence.txt \
		 dist/paragraph.txt

annotate-sentence: ## Annotates the 'dist/sentence.txt' in the Buildkite pipeline.
annotate-sentence: bin/bk-annotate-file.sh dist/sentence.txt
	$< dist/sentence.txt

annotate-paragraph: ## Annotates the 'dist/paragraph.txt' in the Buildkite pipeline.
annotate-paragraph: bin/bk-annotate-file.sh dist/paragraph.txt
	$< dist/paragraph.txt

download-artifacts: # Downloads artifacts in a Buildkite pipeline.
download-artifacts: dist
	buildkite-agent artifact download "$</*" "$</"

#
# Docker.
#

build-image: ## Builds the root Dockerfile in this repository.
build-image: Dockerfile
	docker build \
		$(patsubst %,-t $(REPO):%,$(DOCKER_TAGS)) \
		-f $< .

tag-image-with-registry: # Tags the root Docker image with the Docker registry path.
tag-image-with-registry: build-image
	docker tag $(REPO):$(COMMIT) $(DOCKER_REGISTRY_IMAGE)

push-image: ## Pushes the root Docker image, built from the root Dockerfile, to the Docker registry.
push-image: tag-image-with-registry
	docker push $(DOCKER_REGISTRY_IMAGE)

pull-image: ## Pulls the root Docker image from the Docker registry.
pull-image:
	docker pull $(DOCKER_REGISTRY_IMAGE)

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
