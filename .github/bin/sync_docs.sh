#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -o pipefail
set -e

function exit_with_usage {
  echo "Usage: ./github/bin/sync_docs.sh <ref_name> <target_path>"
  echo ""
  echo "This script synchronizes documentation from the apache/amoro.git repository."
  echo ""
  echo "ref_name can be:"
  echo "  - 'master' for the master branch"
  echo "  - A version number like '0.8.1' which will be converted to tag v0.8.1 or v0.8.1-incubating"
  echo "    (Script will try both v0.8.1-incubating and v0.8.1 tags automatically)"
  echo "  - A branch name like 'feature-branch'"
  echo ""
  echo "target_path is the path where the docs will be copied to, typically 'amoro-docs/content'"
  exit 1
}

if [ $# -ne 2 ]; then
  exit_with_usage
fi

REF_NAME="$1"
TARGET_PATH="$2"

# Create temp directory for downloaded content
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Check if REF_NAME is a version number (e.g., 0.8.1)
if [[ "${REF_NAME}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # First try with v{version} tag
  DOWNLOAD_REF="tags/v${REF_NAME}.tar.gz"
  DIR_NAME="amoro-${REF_NAME}"

  echo "Trying to download ${DOWNLOAD_REF} from Apache Amoro repository..."
  if ! wget -q "https://github.com/apache/amoro/archive/refs/${DOWNLOAD_REF}" -O "${TEMP_DIR}/download.tar.gz" 2>/dev/null; then
    echo "v${REF_NAME} tag not found, trying v${REF_NAME}-incubating tag..."
    # Try with v{version}-incubating tag
    DOWNLOAD_REF="tags/v${REF_NAME}-incubating.tar.gz"
    DIR_NAME="amoro-${REF_NAME}-incubating"

    if ! wget -q "https://github.com/apache/amoro/archive/refs/${DOWNLOAD_REF}" -O "${TEMP_DIR}/download.tar.gz" 2>/dev/null; then
      echo "v${REF_NAME}-incubating tag not found, falling back to branch..."
      # Fall back to branch
      DOWNLOAD_REF="heads/${REF_NAME}.tar.gz"
      DIR_NAME="amoro-${REF_NAME}"
      wget -q "https://github.com/apache/amoro/archive/refs/${DOWNLOAD_REF}" -O "${TEMP_DIR}/download.tar.gz" || {
        echo "Failed to download docs for ${REF_NAME}"
        exit 1
      }
    fi
  fi
elif [ "${REF_NAME}" == "master" ]; then
  DOWNLOAD_REF="heads/master.tar.gz"
  DIR_NAME="amoro-master"

  echo "Downloading ${DOWNLOAD_REF} from Apache Amoro repository..."
  wget -q "https://github.com/apache/amoro/archive/refs/${DOWNLOAD_REF}" -O "${TEMP_DIR}/download.tar.gz" || {
    echo "Failed to download docs for master branch"
    exit 1
  }
else
  # For other branches, use branch name
  DOWNLOAD_REF="heads/${REF_NAME}.tar.gz"
  DIR_NAME="amoro-${REF_NAME}"

  echo "Downloading ${DOWNLOAD_REF} from Apache Amoro repository..."
  wget -q "https://github.com/apache/amoro/archive/refs/${DOWNLOAD_REF}" -O "${TEMP_DIR}/download.tar.gz" || {
    echo "Failed to download docs for branch ${REF_NAME}"
    exit 1
  }
fi

echo "Extracting archive..."
tar -xzf "${TEMP_DIR}/download.tar.gz" -C "${TEMP_DIR}"

echo "Syncing docs to ${TARGET_PATH}..."
# Make sure the target directory exists
mkdir -p "${TARGET_PATH}"
# Clean the target directory
rm -rf "${TARGET_PATH:?}"/*
# Copy the docs to the target directory
cp -r "${TEMP_DIR}/${DIR_NAME}/docs/"* "${TARGET_PATH}/"

echo "Cleanup..."
rm -rf "${TEMP_DIR}"

echo "Sync completed successfully!"
