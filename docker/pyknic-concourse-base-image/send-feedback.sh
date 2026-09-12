#!/bin/bash

# required env-vars are:
#  - BUILD_URL
#  - BUILD_BRANCH
#  - BUILD_PIPELINE_NAME

# optional env-vars are:
#  - TG_BOT_TOKEN
#  - TG_CHAT_ID
#  - TG_API_HOST
#  - GITHUB_PULL_REQUEST_ID
#  - GITHUB_ACCESS_TOKEN
#  - GITHUB_REPO_NAME
#  - GITHUB_PULL_REQUEST_BRANCH_NAME

set -eux
set -o pipefail

TEST_NAME="${1:?}"
TASK_STATE="${2:?}"

source "$(dirname ${0})/settings.sh"

TEST_SYMBOL="${TESTS_SYMBOLS[${TEST_NAME}]}"

if [[ "${TASK_STATE}" != "success" && "${TASK_STATE}" != "failure" ]]; then
  echo "Unknown state spotted -- \"${TASK_STATE}\""
  exit -1
fi

if [[ -n "${TG_BOT_TOKEN:-}" && -n "${TG_CHAT_ID:-}" ]]; then

  TG_API_HOST="${TG_API_HOST:-api.telegram.org}"

  TG_MESSAGE=""
  if [[ "${TASK_STATE}" == "success" ]]; then
    TG_MESSAGE="☘ Test \"${TEST_NAME}\" ${TEST_SYMBOL} succeeded:\n\n"
  elif [[ "${TASK_STATE}" == "failure" ]]; then
    TG_MESSAGE="⚡ Test \"${TEST_NAME}\" ${TEST_SYMBOL} failed:\n\n"
  fi

  TG_MESSAGE="${TG_MESSAGE}Pipeline: ${BUILD_PIPELINE_NAME}\n"
  TG_MESSAGE="${TG_MESSAGE}Build branch: ${BUILD_BRANCH}\n\n"

  if [[ -n "${GITHUB_PULL_REQUEST_ID:-}" ]]; then
  TG_MESSAGE="${TG_MESSAGE}Related PR: https://github.com/${GITHUB_REPO_NAME}/pull/${GITHUB_PULL_REQUEST_ID}\n\n"
  fi

  TG_MESSAGE="${TG_MESSAGE}Build log: ${BUILD_URL}"

  curl \
    -X POST \
    "https://${TG_API_HOST}/bot${TG_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TG_CHAT_ID}" \
    -d text="$(echo -en "${TG_MESSAGE}")"

  echo

fi

if [[ -n "${GITHUB_PULL_REQUEST_ID:-}" && -n "${GITHUB_ACCESS_TOKEN:-}" && -n "${GITHUB_PULL_REQUEST_BRANCH_NAME:-}" ]]; then

    if [[ -z "${_GITHUB_PULL_REQUEST_COMMIT:-}" ]]; then
        _GITHUB_PULL_REQUEST_COMMIT="$(git rev-parse "${GITHUB_PULL_REQUEST_BRANCH_NAME}")"
    fi

  GITHUB_FEEDBACK="{
    \"state\": \"${TASK_STATE}\",
    \"target_url\": \"${BUILD_URL}\",
    \"context\": \"concourse-ci/${TEST_NAME}\"
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

fi
