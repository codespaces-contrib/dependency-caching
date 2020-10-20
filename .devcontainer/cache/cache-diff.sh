#!/bin/bash

# This file is used to archive off a copy of any differences in the source tree into another location
# in the image. Once the codespace is up, this will be restored into its proper location (which is
# quick and happens parallel to other startup activities)

set -e

SCRIPT_PATH="$(cd "$(dirname $0)" && pwd)"
SOURCE_FOLDER="${1:-"."}"
CACHE_FOLDER="${2:-"/usr/local/etc/devcontainer-cache"}"

echo "[$(date)] Starting cache operation..."
cd "${SOURCE_FOLDER}"

echo "[$(date)] Determining changes..."
find -L . \
    -not -path "*/.git/*" \
    -and -not -path "./$(realpath --relative-to='.' "${SCRIPT_PATH}")/*.manifest" \
    -type f \
    -newer "${SCRIPT_PATH}/before-date.manifest" > "${SCRIPT_PATH}/cache.manifest"
echo "[$(date)] Found $(wc -l < "${SCRIPT_PATH}/cache.manifest") changes..."
echo "[$(date)] Archiving changes..."
mkdir -p "${CACHE_FOLDER}"
tar -cf "${CACHE_FOLDER}/cache.tar" --totals --files-from "${SCRIPT_PATH}/cache.manifest"

echo "[$(date)] Done! $(du -h "${CACHE_FOLDER}/cache.tar")"
