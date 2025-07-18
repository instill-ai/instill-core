ARG GOLANG_VERSION=1.24.4
ARG ALPINE_VERSION=3.21
FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS base

RUN apk add --update docker docker-compose docker-cli-compose docker-cli-buildx openrc containerd git bash make wget vim curl openssl util-linux

ARG K6_VERSION XK6_VERSION XK6_SQL_VERSION XK6_SQL_POSTGRES_VERSION
RUN go install go.k6.io/xk6/cmd/xk6@v${XK6_VERSION}
RUN xk6 build v${K6_VERSION} \
  --with github.com/grafana/xk6-sql@v${XK6_SQL_VERSION} \
  --with github.com/grafana/xk6-sql-driver-postgres@v${XK6_SQL_POSTGRES_VERSION} \
  --output /usr/bin/k6

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Kubectl
ARG TARGETARCH
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

ARG API_GATEWAY_COMMIT_SHORT_HASH
ARG PIPELINE_BACKEND_COMMIT_SHORT_HASH
ARG ARTIFACT_BACKEND_COMMIT_SHORT_HASH
ARG MODEL_BACKEND_COMMIT_SHORT_HASH
ARG MGMT_BACKEND_COMMIT_SHORT_HASH
ARG CONSOLE_COMMIT_SHORT_HASH

RUN git clone --depth=1 https://github.com/instill-ai/api-gateway.git
RUN cd api-gateway && git config advice.detachedHead false && git fetch origin && git checkout ${API_GATEWAY_COMMIT_SHORT_HASH}

RUN git clone --depth=1 https://github.com/instill-ai/pipeline-backend.git
RUN cd pipeline-backend && git config advice.detachedHead false && git fetch origin && git checkout ${PIPELINE_BACKEND_COMMIT_SHORT_HASH}

RUN git clone --depth=1 https://github.com/instill-ai/artifact-backend.git
RUN cd artifact-backend && git config advice.detachedHead false && git fetch origin && git checkout ${ARTIFACT_BACKEND_COMMIT_SHORT_HASH}

RUN git clone --depth=1 https://github.com/instill-ai/model-backend.git
RUN cd model-backend && git config advice.detachedHead false && git fetch origin && git checkout ${MODEL_BACKEND_COMMIT_SHORT_HASH}

RUN git clone --depth=1 https://github.com/instill-ai/mgmt-backend.git
RUN cd mgmt-backend && git config advice.detachedHead false && git fetch origin && git checkout ${MGMT_BACKEND_COMMIT_SHORT_HASH}

RUN git clone --depth=1 https://github.com/instill-ai/console.git
RUN cd console && git config advice.detachedHead false && git fetch origin && git checkout ${CONSOLE_COMMIT_SHORT_HASH}

ENV API_GATEWAY_VERSION=${API_GATEWAY_COMMIT_SHORT_HASH}
ENV PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_COMMIT_SHORT_HASH}
ENV ARTIFACT_BACKEND_VERSION=${ARTIFACT_BACKEND_COMMIT_SHORT_HASH}
ENV MODEL_BACKEND_VERSION=${MODEL_BACKEND_COMMIT_SHORT_HASH}
ENV MGMT_BACKEND_VERSION=${MGMT_BACKEND_COMMIT_SHORT_HASH}
ENV CONSOLE_VERSION=${CONSOLE_COMMIT_SHORT_HASH}

FROM alpine:${ALPINE_VERSION} AS release

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=base /lib /lib
COPY --from=docker:dind /usr/local/bin /usr/local/bin

ARG CACHE_DATE
RUN echo "Instill Core release codebase cloned on ${CACHE_DATE}"

WORKDIR /instill-core

ARG API_GATEWAY_VERSION
ARG PIPELINE_BACKEND_VERSION
ARG ARTIFACT_BACKEND_VERSION
ARG MODEL_BACKEND_VERSION
ARG MGMT_BACKEND_VERSION
ARG CONSOLE_VERSION

RUN git clone --depth=1 -b v${API_GATEWAY_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/api-gateway.git
RUN git clone --depth=1 -b v${PIPELINE_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/pipeline-backend.git
RUN git clone --depth=1 -b v${ARTIFACT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/artifact-backend.git
RUN git clone --depth=1 -b v${MODEL_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/model-backend.git
RUN git clone --depth=1 -b v${MGMT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/mgmt-backend.git
RUN git clone --depth=1 -b v${CONSOLE_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/console.git

ENV API_GATEWAY_VERSION=${API_GATEWAY_VERSION}
ENV PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION}
ENV ARTIFACT_BACKEND_VERSION=${ARTIFACT_BACKEND_VERSION}
ENV MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION}
ENV MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION}
ENV CONSOLE_VERSION=${CONSOLE_VERSION}
