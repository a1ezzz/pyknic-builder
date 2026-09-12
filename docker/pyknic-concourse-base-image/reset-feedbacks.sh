#!/bin/bash

# required env-vars are:
#  - PYTHON_VERSION
#  - BUILD_URL

# optional env-vars are:
#  - GITHUB_PULL_REQUEST_ID
#  - GITHUB_ACCESS_TOKEN
#  - GITHUB_REPO_NAME
#  - GITHUB_PULL_REQUEST_BRANCH_NAME

set -eux
set -o pipefail

source "$(dirname ${0})/settings.sh"

if [[ -n "${GITHUB_PULL_REQUEST_ID:-}" && -n "${GITHUB_ACCESS_TOKEN:-}" && -n "${GITHUB_REPO_NAME:-}" && -n "${GITHUB_PULL_REQUEST_BRANCH_NAME}" ]]; then

    if [[ -z "${_GITHUB_PULL_REQUEST_COMMIT:-}" ]]; then

        git fetch origin "${GITHUB_PULL_REQUEST_BRANCH_NAME}:${GITHUB_PULL_REQUEST_BRANCH_NAME}"

        _GITHUB_PULL_REQUEST_COMMIT="$(git rev-parse "${GITHUB_PULL_REQUEST_BRANCH_NAME}")"
    fi

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
            "https://api.github.com/repos/${GITHUB_REPO_NAME}/statuses/${_GITHUB_PULL_REQUEST_COMMIT}" \
            -d "${GITHUB_FEEDBACK}"

        echo

    done

fi
