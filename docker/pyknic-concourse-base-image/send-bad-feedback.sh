#!/bin/bash

# required env-vars are:
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
#  - GITHUB_PULL_REQUEST_BRANCH_NAME

set -eux
set -o pipefail

source "$(dirname ${0})/settings.sh"

"$(dirname "${0}")/send-feedback.sh" "${1}" failure

echo > "${ERR_FEEDBACK_FILE}"
