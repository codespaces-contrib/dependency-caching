#!/bin/bash

# This file simply wraps the dockeer build command used to build the image with the
# cached result of the commands from "prepare.sh" and pushes it to the specified
# container image registry.

set -e

if [ "$1" = "" ] || [ "$2" = "" ] ; then
	echo "Command missing required arguments!"
	exit 1
fi

BASE_IMAGE_ID="$1"
TARGET_IMAGE_REPOSITORY="$(echo "$2" | grep  -o -E '[^@:]*' | head -n 1)"
USERNAME="${3:-"root"}"
BUILD_CONTEXT="$(cd "${4:-"."}" && pwd)"
COMMIT_PINNING="${5:-"false"}"
UPDATE_DEVCONTAINER_JSON_TYPE="${6:-"false"}"
ADDITIONAL_BUILD_COMMAND_ARGS="${7:-"none"}"
ADDITIONAL_PUSH_COMMAND_ARGS="${8:-"none"}"

if [ "${ADDITIONAL_BUILD_COMMAND_ARGS}" = "none" ]; then
	ADDITIONAL_BUILD_COMMAND_ARGS=""
fi

if [ "${ADDITIONAL_PUSH_COMMAND_ARGS}" = "none" ]; then
	ADDITIONAL_PUSH_COMMAND_ARGS=""
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
BRANCH_TAG="branch-${BRANCH//\//-}"
BRANCH_IMAGE_ID="${TARGET_IMAGE_REPOSITORY}:${BRANCH_TAG}"

echo "[$(date)] Starting image build..."
SCRIPT_PATH="$(cd "$(dirname $0)" && pwd)"
cd "${SCRIPT_PATH}/../.."
docker build -t "${BRANCH_IMAGE_ID}" -f "${SCRIPT_PATH}/cache.Dockerfile" --build-arg BASE_IMAGE_ID=${BASE_IMAGE_ID} --build-arg USERNAME=${USERNAME} ${ADDITIONAL_BUILD_COMMAND_ARGS} "${BUILD_CONTEXT}"
echo "[$(date)] Image build complete."

echo "[$(date)] Pushing image..."
docker push "${BRANCH_IMAGE_ID}" ${ADDITIONAL_PUSH_COMMAND_ARGS}
TARGET_IMAGE_ID="${BRANCH_IMAGE_ID}"
if [ "${COMMIT_PINNING}" = "true" ]; then
	COMMIT_ID="$(git rev-parse --short=15 HEAD)"
	COMMIT_IMAGE_ID="${TARGET_IMAGE_REPOSITORY}:commit-${COMMIT_ID}"
	docker tag "${BRANCH_IMAGE_ID}" "${COMMIT_IMAGE_ID}"
	docker push "${COMMIT_IMAGE_ID}" ${ADDITIONAL_PUSH_COMMAND_ARGS}
	TARGET_IMAGE_ID="${COMMIT_IMAGE_ID}"
fi
echo "[$(date)] Push complete."

if [ "${UPDATE_DEVCONTAINER_JSON_TYPE}" != "false" ]; then
	echo "[$(date)] Updating devcontainer.json..."
	# Value of "true" or "image" means there's an image refernece that should be updated in devcontainer.json
	if [ "${UPDATE_DEVCONTAINER_JSON_TYPE}" = "image" ] || [ "${UPDATE_DEVCONTAINER_JSON_TYPE}" = "true" ]; then
		sed -i -E "s/\"image\"\s*:\s*\".*\"/\"image\": \"${TARGET_IMAGE_ID//\//\\\/}\"/" "${SCRIPT_PATH}/../devcontainer.json"
	else
		# Otherwise its a Dockerfile file path
		sed -i -E "s/ARG\s+IMAGE_ID\s*=.*/ARG IMAGE_ID=\"${TARGET_IMAGE_ID//\//\\\/}\"/g" "${UPDATE_DEVCONTAINER_JSON_TYPE}"
	fi
fi
echo "[$(date)] Done!"
