#!/bin/bash

# This file establishes a basline for the reposuitory before any steps in the "prepare.sh"
# All it does is create a marker file that can be used to determine which files have been
# created or modified in the source tree.

set -e

SCRIPT_PATH="$(cd "$(dirname $0)" && pwd)"
SOURCE_FOLDER="${1:-"."}"

cd "${SOURCE_FOLDER}"
echo "[$(date)] Recording before date/time..."
touch "${SCRIPT_PATH}/before-date.manifest"
echo "[$(date)] Done!"

