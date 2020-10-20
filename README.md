# Dependency Caching

This repository covers an approach that uses GitHub Actions and a container image registry (in this case GitHub Container Registry) to pre-build a dev container image and then use a secondary image to cache additional pre-requisites that cannot be built into the image or change too often to be in the primary layer.

It includes the following:

1. **[devcontainer.yml](.github/workflows/devcontainer.yml)**: A GitHub Actions workflow that build and publishes a the base dev container image using [.devcontainer/base.Dockerfile](.devcontainer/base.Dockerfile) whenever it is updated.
2. **[devcontainer-cache.yml](.github/workflows/devcontainer-cache.yml)**: Another workflow that watches for updates to key dependency files (in this case `yarn.lock`) and uses the scripts under [.devcontainer/cache](.devcontainer/cache) to cache these in another image that is tagged with the branch name.
3. **[.devcontainer/prepare.sh](.devcontainer/prepare.sh):** Covers the steps that should be executed when starting from the dev container image to create the cache.
4. **[.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)**: A simple example that points to the image for the `main` branch and uses a `postCreateCommand` to restore the cached files in the source tree.

The logic to do the caching is then entirely in scripts in the [.devcontainer/cache](.devcontainer/cache) folder.

The caching operation results in an automated update to devcontainer.json to update the image reference to one created for the specific comment. Once an update happens, a new cache image is generated and once again referenced. However, the full git history is not required to determine which cache image to use, so this model works with shallow clones as well.
