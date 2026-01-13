---
title: "Install with Docker | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/docker-install"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Install dbt Core](https://docs.getdbt.com/docs/core/installation-overview)* Install with Docker

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fdocker-install+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fdocker-install+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fdocker-install+so+I+can+ask+questions+about+it.)

On this page

dbt Core and all adapter plugins maintained by dbt Labs are available as [Docker](https://docs.docker.com/) images, and distributed via [GitHub Packages](https://docs.github.com/en/packages/learn-github-packages/introduction-to-github-packages) in a [public registry](https://github.com/dbt-labs/dbt-core/pkgs/container/dbt-core).

Using a prebuilt Docker image to install dbt Core in production has a few benefits: it already includes dbt-core, one or more database adapters, and pinned versions of all their dependencies. By contrast, `python -m pip install dbt-core dbt-<adapter>` takes longer to run, and will always install the latest compatible versions of every dependency.

You might also be able to use Docker to install and develop locally if you don't have a Python environment set up. Note that running dbt in this manner can be significantly slower if your operating system differs from the system that built the Docker image. If you're a frequent local developer, we recommend that you install dbt Core using [pip](https://docs.getdbt.com/docs/core/pip-install) instead.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You've installed Docker. For more information, see the [Docker](https://docs.docker.com/) site.
* You understand which database adapter(s) you need. For more information, see [About dbt adapters](https://docs.getdbt.com/docs/core/installation-overview#about-dbt-data-platforms-and-adapters).
* You understand how dbt Core is versioned. For more information, see [About dbt Core versions](https://docs.getdbt.com/docs/dbt-versions/core).
* You have a general understanding of the dbt, dbt workflow, developing locally in the command line interface (CLI). For more information, see [About dbt](https://docs.getdbt.com/docs/introduction#how-do-i-use-dbt).

### Install a dbt Docker image from Github Packages[​](#install-a-dbt-docker-image-from-github-packages "Direct link to Install a dbt Docker image from Github Packages")

Official dbt docker images are hosted as [packages in the `dbt-labs` GitHub organization](https://github.com/orgs/dbt-labs/packages?visibility=public). We maintain images and tags for every version of every database adapter, as well as two tags that update as new versions as released:

* `latest`: Latest overall version of dbt-core + this adapter
* `<Major>.<Minor>.latest`: Latest patch of dbt-core + this adapter for `<Major>.<Minor>` version family. For example, `1.1.latest` includes the latest patches for dbt Core v1.1.

Install an image using the `docker pull` command:

```
docker pull ghcr.io/dbt-labs/<db_adapter_name>:<version_tag>
```

### Running a dbt Docker image in a container[​](#running-a-dbt-docker-image-in-a-container "Direct link to Running a dbt Docker image in a container")

The `ENTRYPOINT` for dbt Docker images is the command `dbt`. You can bind-mount your project to `/usr/app` and use dbt as normal:

```
docker run \
--network=host \
--mount type=bind,source=path/to/project,target=/usr/app \
--mount type=bind,source=path/to/profiles.yml,target=/root/.dbt/profiles.yml \
<dbt_image_name> \
ls
```

Or

```
docker run \
--network=host \
--mount type=bind,source=path/to/project,target=/usr/app \
--mount type=bind,source=path/to/profiles.yml.dbt,target=/root/.dbt/ \
<dbt_image_name> \
ls
```

Notes:

* Bind-mount sources *must* be an absolute path
* You may need to make adjustments to the docker networking setting depending on the specifics of your data warehouse or database host.

### Building your own dbt Docker image[​](#building-your-own-dbt-docker-image "Direct link to Building your own dbt Docker image")

If the pre-made images don't fit your use case, we also provide a [`Dockerfile`](https://github.com/dbt-labs/dbt-core/blob/main/docker/Dockerfile) and [`README`](https://github.com/dbt-labs/dbt-core/blob/main/docker/README.md) that can be used to build custom images in a variety of ways.

In particular, the Dockerfile supports building images:

* Images that all adapters maintained by dbt Labs
* Images that install one or more third-party adapters
* Images against another system architecture

Please note that, if you go the route of building your own Docker images, we are unable to offer dedicated support for custom use cases. If you run into problems, you are welcome to [ask the community for help](https://docs.getdbt.com/community/resources/getting-help) or [open an issue](https://docs.getdbt.com/community/resources/contributor-expectations#issues) in the `dbt-core` repository. If many users are requesting the same enhancement, we will tag the issue `help_wanted` and invite community contribution.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About dbt Core installation](https://docs.getdbt.com/docs/core/installation-overview)[Next

Install with pip](https://docs.getdbt.com/docs/core/pip-install)

* [Prerequisites](#prerequisites)* [Install a dbt Docker image from Github Packages](#install-a-dbt-docker-image-from-github-packages)* [Running a dbt Docker image in a container](#running-a-dbt-docker-image-in-a-container)* [Building your own dbt Docker image](#building-your-own-dbt-docker-image)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/docker-install.md)
