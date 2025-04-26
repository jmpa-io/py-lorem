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

* [Using plugins](https://buildkite.com/docs/pipelines/integrations/plugins/using).
* [A warning about using an array / multi-ling string as a command in the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin?tab=readme-ov-file#run).
