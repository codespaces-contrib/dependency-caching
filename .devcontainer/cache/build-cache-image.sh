#!/bin/bash

# This file simply wraps the dockeer build command used to build the image with the
# cached result of the commands from "prepare.sh" and pushes it to the specified
# container image registry.

set -e

SCRIPT_PATH="$(cd "$(dirname $0)" && pwd)"
BASE_IMAGE="$1"
TARGET_IMAGE="$2"
BRANCH="${3:-"master"}"
USERNAME="${4:-"root"}"

if [ "${BASE_IMAGE}" = "" ] || [ "${TARGET_IMAGE}" = "" ] ; then
	echo "Command missing required arguments!"
	exit 1
fi

TAG="${BRANCH//\//-}"
echo "[$(date)] ${BRANCH} => ${TAG}"
cd "${SCRIPT_PATH}/../.."

echo "[$(date)] Starting image build..."
docker build -t "${TARGET_IMAGE}:${TAG}" -f "${SCRIPT_PATH}/cache.Dockerfile" --build-arg BASE_IMAGE=${BASE_IMAGE} --build-arg USERNAME=${USERNAME} .
echo "[$(date)] Image build complete."

echo "[$(date)] Pushing image..."
docker push "${TARGET_IMAGE}:${TAG}"
echo "[$(date)] Done!"
