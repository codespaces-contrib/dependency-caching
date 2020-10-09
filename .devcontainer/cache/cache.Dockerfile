# This dockerfile is used to build up from a base image to create an image with cached results of running "prepare.sh".
ARG BASE_IMAGE
FROM ${BASE_IMAGE} as cache
ARG USERNAME
COPY --chown=${USERNAME}:${USERNAME} . /repo-source-tmp/
RUN mkdir /usr/local/etc/devcontainer-cache \
	&& chown ${USERNAME} /usr/local/etc/devcontainer-cache /repo-source-tmp \
	&& su ${USERNAME} -c "\
		cd /repo-source-tmp \
		&& .devcontainer/cache/before-cache.sh \
		&& .devcontainer/prepare.sh \
		&& .devcontainer/cache/cache-diff.sh" \
	&& rm -rf /repo-source-tmp


# This optional section copies the workspace cache file to into a fresh image to keep the image as small 
# as possible. Add other "COPY" statements if you want to include things located in other paths in the image.
# Alternativley, you can simply remove this section and whatever was installed above will be in the image.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG USERNAME
COPY --from=cache --chown=${USERNAME}:${USERNAME} /usr/local/etc/devcontainer-cache/* /usr/local/etc/devcontainer-cache/
