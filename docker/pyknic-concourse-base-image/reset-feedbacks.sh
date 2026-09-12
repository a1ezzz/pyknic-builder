#!/bin/bash

# required env-vars are:
#  - PYTHON_VERSION
#  - BUILD_URL
#  - BUILD_COMMIT

# optional env-vars are:
#  - GITHUB_PULL_REQUEST_ID
#  - GITHUB_ACCESS_TOKEN

set -eux
set -o pipefail

BUILD_URL="${BUILD_URL:?}"
BUILD_COMMIT="${BUILD_COMMIT:?}"

source "$(dirname ${0})/settings.sh"

if [[ -n "${GITHUB_PULL_REQUEST_ID:-}" && -n "${GITHUB_ACCESS_TOKEN:-}" ]]; then

    for _TEST_NAME in "${TEST_NAME_PYTEST}" "${TEST_NAME_FLAKE8}" "${TEST_NAME_MYPY}"; do

        echo "Reseting feedback for: ${_TEST_NAME}"

        GITHUB_FEEDBACK="{
            \"state\": \"pending\",
            \"target_url\": \"${BUILD_URL}\",
            \"context\": \"concourse-ci/${_TEST_NAME}\"
        }"

        curl \
            -L \
            -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${GITHUB_ACCESS_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "https://api.github.com/repos/a1ezzz/pyknic/statuses/${BUILD_COMMIT}" \
            -d "${GITHUB_FEEDBACK}"

        echo

    done

fi
