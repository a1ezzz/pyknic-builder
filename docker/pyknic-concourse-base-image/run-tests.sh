#!/bin/bash

# required env-vars are:
#  - CODE_DIR
#  - PYTHON_VERSION
#  - BUILD_URL
#  - BUILD_BRANCH
#  - BUILD_COMMIT
#  - BUILD_PIPELINE_NAME
#  - SANDBOX_DIR

# optional env-vars are:
#  - TG_BOT_TOKEN
#  - TG_CHAT_ID
#  - TG_API_HOST
#  - GITHUB_PULL_REQUEST_ID
#  - GITHUB_ACCESS_TOKEN

set -eux
set -o pipefail

# TODO: split to different scripts?

source "$(dirname ${0})/settings.sh"

cd "${CODE_DIR}"

if [[ -n "${GITHUB_PULL_REQUEST_ID}" ]]; then

    /scripts/reset-feedbacks.sh

    git config user.email "john-doe@concourse-ci"
    git config user.name "John Doe-Concourse"

    # TODO: make a message!!!!
    [[ -z "${GITHUB_PULL_REQUEST_BRANCH_NAME}" ]] && exit -1;

    git fetch origin '${PULL_REQUEST_BRANCH_NAME}:${PULL_REQUEST_BRANCH_NAME}'
    git merge '${PULL_REQUEST_BRANCH_NAME}' --no-commit

fi

# TODO: reset statuses on start!

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
