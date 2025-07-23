ARG GOLANG_VERSION=1.24.4
ARG ALPINE_VERSION=3.21
FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS base

RUN apk add --update git bash make wget vim curl

ARG K6_VERSION XK6_VERSION XK6_SQL_VERSION XK6_SQL_POSTGRES_VERSION
RUN go install go.k6.io/xk6/cmd/xk6@v${XK6_VERSION}
RUN xk6 build v${K6_VERSION} \
  --with github.com/grafana/xk6-sql@v${XK6_SQL_VERSION} \
  --with github.com/grafana/xk6-sql-driver-postgres@v${XK6_SQL_POSTGRES_VERSION} \
  --output /usr/bin/k6

FROM alpine:${ALPINE_VERSION} AS release

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=base /lib /lib

ARG CACHE_DATE
RUN echo "Instill Core release codebase cloned on ${CACHE_DATE}"

WORKDIR /instill-core

ARG API_GATEWAY_VERSION
ARG PIPELINE_BACKEND_VERSION
ARG ARTIFACT_BACKEND_VERSION
ARG MODEL_BACKEND_VERSION
ARG MGMT_BACKEND_VERSION
ARG CONSOLE_VERSION

ENV SEMATIC_VERSION_REGEX="^[0-9]+\.[0-9]+\.[0-9]+"

RUN if echo "${API_GATEWAY_VERSION}" | grep -qE ${SEMATIC_VERSION_REGEX}; then \
        git clone --depth=1 -b v${API_GATEWAY_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/api-gateway.git; \
    else \
        # TODO: we should implement a better way to shallow clone the repo
        git clone https://github.com/instill-ai/api-gateway.git; \
        cd api-gateway; \
        git checkout ${API_GATEWAY_VERSION}; \
    fi

RUN if echo "${PIPELINE_BACKEND_VERSION}" | grep -qE ${SEMATIC_VERSION_REGEX}; then \
        git clone --depth=1 -b v${PIPELINE_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/pipeline-backend.git; \
    else \
        # TODO: we should implement a better way to shallow clone the repo
        git clone https://github.com/instill-ai/pipeline-backend.git; \
        cd pipeline-backend; \
        git checkout ${PIPELINE_BACKEND_VERSION}; \
    fi

RUN if echo "${ARTIFACT_BACKEND_VERSION}" | grep -qE ${SEMATIC_VERSION_REGEX}; then \
        git clone --depth=1 -b v${ARTIFACT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/artifact-backend.git; \
    else \
        # TODO: we should implement a better way to shallow clone the repo
        git clone https://github.com/instill-ai/artifact-backend.git; \
        cd artifact-backend; \
        git checkout ${ARTIFACT_BACKEND_VERSION}; \
    fi

RUN if echo "${MODEL_BACKEND_VERSION}" | grep -qE ${SEMATIC_VERSION_REGEX}; then \
        git clone --depth=1 -b v${MODEL_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/model-backend.git; \
    else \
        # TODO: we should implement a better way to shallow clone the repo
        git clone https://github.com/instill-ai/model-backend.git; \
        cd model-backend; \
        git checkout ${MODEL_BACKEND_VERSION}; \
    fi

RUN if echo "${MGMT_BACKEND_VERSION}" | grep -qE ${SEMATIC_VERSION_REGEX}; then \
        git clone --depth=1 -b v${MGMT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/mgmt-backend.git; \
    else \
        # TODO: we should implement a better way to shallow clone the repo
        git clone https://github.com/instill-ai/mgmt-backend.git; \
        cd mgmt-backend; \
        git checkout ${MGMT_BACKEND_VERSION}; \
    fi

ENV API_GATEWAY_VERSION=${API_GATEWAY_VERSION}
ENV PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION}
ENV ARTIFACT_BACKEND_VERSION=${ARTIFACT_BACKEND_VERSION}
ENV MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION}
ENV MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION}
ENV CONSOLE_VERSION=${CONSOLE_VERSION}
