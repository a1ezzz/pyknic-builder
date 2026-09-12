#!/bin/bash

set -eu
set -o pipefail

CONCOURSE_VERSION="${CONCOURSE_VERSION:-7.13.2}"

cd "$(dirname "${0}")/docker"

echo "==> Builiding and pushing base image..."

for _PY_VER in "3.10" "3.11" "3.12" "3.13" "3.14"; do

  _IMG_NAME="a1ezzz/pyknic-concourse-base-image:py-alpine-${_PY_VER}"

  echo
  echo "==> Building ${_IMG_NAME} ..."
  echo

  docker \
    build \
    --build-arg BASE_PYTHON_VERSION="${_PY_VER}" \
    -t "${_IMG_NAME}" \
    pyknic-concourse-base-image

  echo "==> Pushing ${_IMG_NAME} ..."
  docker push "${_IMG_NAME}"
  echo

done

_GIT_IMG_NAME="a1ezzz/pyknic-local-test-git:$(date '+%y%m%d')"

echo
echo "==> Building ${_GIT_IMG_NAME} ..."
docker \
  build \
  -t "${_GIT_IMG_NAME}" \
  pyknic-local-test-git
echo
echo "==> Pushing ${_GIT_IMG_NAME} ..."
docker push "${_GIT_IMG_NAME}"
echo

_FLY_IMG_NAME="a1ezzz/pyknic-local-test-runner:${CONCOURSE_VERSION}"

echo
echo "==> Building ${_FLY_IMG_NAME} ..."
docker \
  build \
  --build-arg CONCOURSE_VERSION="${CONCOURSE_VERSION}" \
  -t "${_FLY_IMG_NAME}" \
  pyknic-local-test-runner
echo
echo "==> Pushing ${_FLY_IMG_NAME} ..."
docker push "${_FLY_IMG_NAME}"
echo
