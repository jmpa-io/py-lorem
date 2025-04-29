[![Build status](https://badge.buildkite.com/26ac7f956860649b8a27c352cea5f6d6fa1999d8c9fb88843d.svg)](https://buildkite.com/jmpa-io/py-lorem)

`py-lorem`
========

```diff
+ ✏️ Lorem Ipsum library for Python. 
```

Install
-------

```shell
pip install py-lorem
```

Usage
-------

```python
import loremipsum

# generate a random sentence of max 20 chars.
loremipsum.sentence(max_char=20)

# generate a random sentence of arbitrary length.
loremipsum.sentence()

# generate a random paragraph of max 100 chars.
loremipsum.paragraph(max_char=100)

# generate a random paragraph of arbitrary length.
loremipsum.paragraph()
```

For running this project, using a <kbd>terminal</kbd>, run

```bash
make
# or
make help
```
For a list of full commands.

Design rationale 
------

Below are some design decisions I've used in this task:

* I've chosen to use Docker volumes over copying files into Docker images because I feel it's cleaner.
* I've chosen to not to mount `buildkite-agent` into the Docker container (via [the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin?tab=readme-ov-file#mount-buildkite-agent-optional-boolean)) because I feel CI/CD should have some separation from the runtime Docker environments used in CI/CD - this is largely so that the Docker images used in CI/CD match local development more closely.
* Most files or scripts under `./bin/` have a `number-` prefix; This indicates the order of execution in the CI/CD pipeline. Any files in this directory without this prefix are intended to be run sporadically, either locally or in the CI/CD pipeline.
* The `pre-command` hook in this repository is run on steps that don’t need it. In production, I would switch this process so that a generic Python image is built for all my Python projects and this image would be used here in the pipeline for this repository. Using the `pre-command` hook this way kind of mimics this way of working.

Repository breakdown
-------

File|Description
:---|:---
[`Makefile`](./Makefile)|The entrypoint to this repository - this is used to run all the other commands used both locally and in the Buildkite pipeline (see `make` or `make help` for all the commands).
---|---
[`buildkite.yml`](./buildkite.yml)|The **root** Buildkite pipeline for this repository. This file is outside the `.buildkite` directory so that it is more in-your-face and shown to be an important file.
[`Dockerfile`](./Dockerfile)|The **root** Dockerfile in this repository - this image is used to run this project inside a Docker image locally, as well as being the artifact that is pushed to *Buildkite's Docker registry.*
[`.buildkite/hooks/pre-command`](./.buildkite/hooks/pre-command)|A `pre-command` hook used to build the `Dockerfile` locally on each step in a Buildkite pipeline. While not ideal, the intention is to use this Docker image in each step in the pipeline required to run in a Docker container.
---|---
[`bin/10-lint.sh`](./bin/10-lint.sh)|A script used to demonstrate my skills with writing Bash scripts - this script runs all the linting it can, as of writing.<br/><br/>**Please note:** This is not a script I would have in this repository if this was in production - ideally this function and linting code would be within the Makefile itself - it's only here to showcase my experience.
[`bin/20-generate-sentence.py`](./bin/20-generate-sentence.py)|A Python file to simplify creating `dist/sentence.txt`.
[`bin/30-generate-paragraph.py`](./bin/30-generate-paragraph.py)|A Python file to simplify creating `dist/paragraph.txt`.
[`bin/bk-annotate-file.sh`](./bin/bk-annotate-file.sh)|Another script to demonstrate my skills with writing Bash scripts - this script is used to wrap annotating a given file and sending it through to `buildkite-agent annotate` - it's only intended to be run in the Buildkite pipeline.

Challenges faced
-------

1. Using the Docker plugin in the pipeline.
    * I've found code is easier to manage when the control of Docker is outside CI/CD, so that whatever I run is able to be run both locally and in the pipeline and they match - if one changes the other changes. I understand the `bk` CLI can run pipelines though.

2. I installed a `buildkite-agent` manually inside my homelab; My homelab is new to me and still being setup - there were some teething issues that were fun to fix.

3. Below are some technical issues that still exist but I'm aware of:

    * The `pre-command` hook in this repository is run on steps that don't need it. In production, I would switch this process so that a generic Python image is built for all my Python projects and this image would be used here in the pipeline for this repository.

4. It's been a while since I worked on a Buildkite pipeline, so I had to refresh a little.
    
References / Notes
------

Below are some references & some notes I took while doing this task:

* [Installing `buildite-agent` on Debian](https://buildkite.com/docs/agent/v3/debian).
* [Using plugins](https://buildkite.com/docs/pipelines/integrations/plugins/using).
* [Using build artifacts](https://buildkite.com/docs/pipelines/configure/artifacts).
* [Using `buildkite-agent annotate`](https://buildkite.com/docs/agent/v3/cli-annotate).
* [Using `hooks`](https://buildkite.com/docs/agent/v3/hooks).
* [A warning about using an array / multi-line string as a command in the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin?tab=readme-ov-file#run).
* [Pushing an Docker image to the Buildkite artifact registry](https://buildkite.com/docs/package-registries/container).
* (I chose not to use this but nice to know it's possible) [Run pipelines locally with `bk`](https://buildkite.com/resources/changelog/44-run-pipelines-locally-with-bk-cli/).

License
-------

The license for this is to of do-whatever-the-hell-you-want-with-it :)

Authors
-------

* nubela (nubela@gmail.com).
* jcleal (https://github.com/jcleal).
