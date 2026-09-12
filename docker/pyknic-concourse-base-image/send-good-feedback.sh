#!/bin/bash

# required env-vars are:
#  - BUILD_URL
#  - BUILD_BRANCH
#  - BUILD_COMMIT
#  - BUILD_PIPELINE_NAME

# optional env-vars are:
#  - TG_BOT_TOKEN
#  - TG_CHAT_ID
#  - TG_API_HOST
#  - GITHUB_PULL_REQUEST_ID
#  - GITHUB_ACCESS_TOKEN
#  - GITHUB_REPO_NAME

set -eux
set -o pipefail

"$(dirname "${0}")/send-feedback.sh" "${1}" success
