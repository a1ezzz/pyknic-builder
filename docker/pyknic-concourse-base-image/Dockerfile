
# in order to build with other version call this: docker build --build-arg BASE_PYTHON_VERSION=3.12 ...
ARG BASE_PYTHON_VERSION=3.11

FROM python:${BASE_PYTHON_VERSION}-alpine AS builder

# this makes cache hotter!
RUN mkdir -p /pip-cache && pip3 --cache-dir /pip-cache install virtualenv mypy pyknic[all] && mypy --install-types --non-interactive

FROM python:${BASE_PYTHON_VERSION}-alpine

RUN apk add --no-cache curl git bash jq

COPY --from=builder /pip-cache /pip-cache

COPY settings.sh /scripts/settings.sh
COPY run-tests.sh /scripts/run-tests.sh
COPY reset-feedbacks.sh /scripts/reset-feedbacks.sh
COPY send-feedback.sh /scripts/send-feedback.sh
COPY send-bad-feedback.sh /scripts/send-bad-feedback.sh
COPY send-good-feedback.sh /scripts/send-good-feedback.sh
