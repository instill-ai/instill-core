ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION} AS base

RUN apk add --update docker docker-compose docker-cli-compose docker-cli-buildx openrc containerd git bash make wget vim curl openssl util-linux

# Install k6
ARG TARGETARCH K6_VERSION XK6_VERSION

FROM golang:alpine${ALPINE_VERSION}
RUN go install go.k6.io/xk6/cmd/xk6@v${XK6_VERSION}
RUN xk6 build v${K6_VERSION} --with github.com/grafana/xk6-sql --output /usr/bin/k6

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

FROM alpine:${ALPINE_VERSION} AS latest

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=base /lib /lib
COPY --from=docker:dind /usr/local/bin /usr/local/bin

ARG CACHE_DATE
RUN echo "Instill Core latest codebase cloned on ${CACHE_DATE}"

WORKDIR /instill-core

ARG CONTROLLER_MODEL_VERSION
RUN git clone --depth=1 https://github.com/instill-ai/artifact-backend.git
RUN git clone --depth=1 https://github.com/instill-ai/api-gateway.git
RUN git clone --depth=1 https://github.com/instill-ai/mgmt-backend.git
RUN git clone --depth=1 https://github.com/instill-ai/console.git
RUN git clone --depth=1 https://github.com/instill-ai/pipeline-backend.git
RUN git clone --depth=1 https://github.com/instill-ai/model-backend.git

FROM alpine:${ALPINE_VERSION} AS release

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=base /lib /lib
COPY --from=docker:dind /usr/local/bin /usr/local/bin

ARG CACHE_DATE
RUN echo "Instill Core release codebase cloned on ${CACHE_DATE}"

WORKDIR /instill-core

ARG API_GATEWAY_VERSION MGMT_BACKEND_VERSION CONSOLE_VERSION PIPELINE_BACKEND_VERSION MODEL_BACKEND_VERSION ARTIFACT_BACKEND_VERSION CONTROLLER_MODEL_VERSION
RUN git clone --depth=1 -b v${API_GATEWAY_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/api-gateway.git
RUN git clone --depth=1 -b v${MGMT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/mgmt-backend.git
RUN git clone --depth=1 -b v${CONSOLE_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/console.git
RUN git clone --depth=1 -b v${PIPELINE_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/pipeline-backend.git
RUN git clone --depth=1 -b v${MODEL_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/model-backend.git
RUN git clone --depth=1 -b v${ARTIFACT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/artifact-backend.git
