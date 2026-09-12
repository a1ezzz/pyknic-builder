#!/bin/bash

# required env-vars are:
#  - CODE_DIR
#  - PYTHON_VERSION
#  - BUILD_URL
#  - BUILD_BRANCH
#  - BUILD_PIPELINE_NAME
#  - SANDBOX_DIR

# optional env-vars are:
#  - TG_BOT_TOKEN
#  - TG_CHAT_ID
#  - TG_API_HOST
#  - GITHUB_PULL_REQUEST_ID
#  - GITHUB_ACCESS_TOKEN
#  - GITHUB_REPO_NAME

set -eux
set -o pipefail

source "$(dirname ${0})/settings.sh"

cd "${CODE_DIR}"

if [[ -n "${GITHUB_PULL_REQUEST_ID}" ]]; then

    git config user.email "john-doe@concourse-ci"
    git config user.name "John Doe-Concourse"

    [[ -z "${GITHUB_PULL_REQUEST_BRANCH_NAME}" ]] && exit -1;

    git fetch origin "${GITHUB_PULL_REQUEST_BRANCH_NAME}:${GITHUB_PULL_REQUEST_BRANCH_NAME}"
    _GITHUB_PULL_REQUEST_COMMIT=$(git rev-parse "${GITHUB_PULL_REQUEST_BRANCH_NAME}")

    /scripts/reset-feedbacks.sh

    git merge "${GITHUB_PULL_REQUEST_BRANCH_NAME}" --no-commit
fi

pip3 --cache-dir "${PIP_CACHE_DIR}" install virtualenv
virtualenv -p /usr/local/bin/python "${VENV_DIR}"

pip cache info --cache-dir "${PIP_CACHE_DIR}"
echo
source "${VENV_DIR}/bin/activate"
"${VENV_DIR}/bin/pip3" --cache-dir "${PIP_CACHE_DIR}" install '.[all]'
echo
pip3 cache info --cache-dir "${PIP_CACHE_DIR}"

mypy --install-types --non-interactive

pytest || ("$(dirname ${0})/send-bad-feedback.sh" "${TEST_NAME_PYTEST}"; exit -1;)
"$(dirname ${0})/send-good-feedback.sh" "${TEST_NAME_PYTEST}"

flake8 || ("$(dirname ${0})/send-bad-feedback.sh" "${TEST_NAME_FLAKE8}"; exit -1;)
"$(dirname ${0})/send-good-feedback.sh" "${TEST_NAME_FLAKE8}"

mypy || ("$(dirname ${0})/send-bad-feedback.sh" "${TEST_NAME_MYPY}"; exit -1;)
"$(dirname ${0})/send-good-feedback.sh" "${TEST_NAME_MYPY}"
