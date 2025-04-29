[![Build status](https://badge.buildkite.com/26ac7f956860649b8a27c352cea5f6d6fa1999d8c9fb88843d.svg)](https://buildkite.com/jmpa-io/py-lorem)

py-lorem
========

```diff
+ ✏️ Lorem Ipsum library for Python. 
```

Install
=======

    pip install py-lorem

Usage
=======

    import loremipsum

    #generate a random sentence of max 20 chars
    loremipsum.sentence(max_char=20)

    #generate a random sentence of arbitrary length
    loremipsum.sentence()

    #generate a random paragraph of max 100 chars
    loremipsum.paragraph(max_char=100)

    #generate a random paragraph of arbitrary length
    loremipsum.paragraph()

License
=======

The license for this is to of do-whatever-the-hell-you-want-with-it :)

Author
=======

* nubela (nubela@gmail.com).

Design decisions
=======

* Use Docker volumes over Docker copy.
* Choosing not to mount `buildkite-agent` into Docker container (via [this](https://github.com/buildkite-plugins/docker-buildkite-plugin?tab=readme-ov-file#mount-buildkite-agent-optional-boolean)) because I feel Buildkite should be separated from running inside the runtime Docker environments.

Repository breakdown
=======

File|Description
:---|:---
[buildkite.yml](./buildkite.yml)|The **root** Buildkite pipeline.yml for this repository.

References / Notes
=======

* [Installing `buildite-agent` on Debian](https://buildkite.com/docs/agent/v3/debian).
* [Using plugins](https://buildkite.com/docs/pipelines/integrations/plugins/using).
* [Using build artifacts](https://buildkite.com/docs/pipelines/configure/artifacts).
* [Using `buildkite-agent annotate`](https://buildkite.com/docs/agent/v3/cli-annotate).
* [A warning about using an array / multi-line string as a command in the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin?tab=readme-ov-file#run).
* [Pushing an Docker image to the Buildkite artifact registry](https://buildkite.com/docs/package-registries/container).


Challenges faced
=======

* Using the Docker plugin in the pipeline.
    * I've found code easier to manage when the control of Docker is outside CI/CD, so that whatever I run is able to be run both locally and in the pipeline and they match - if one changes the other changes. I understand the `bk` CLI can run pipelines though.

* I installed a `buildkite-agent` manually inside my homelab, which is new and still being setup - there were some teething issues.
