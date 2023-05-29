ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION} AS base

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin \
    git \
    bash \
    make \
    wget \
    vim && rm -rf /var/lib/apt/lists/*

# Install k6
ARG TARGETARCH K6_VERSION
ADD https://github.com/grafana/k6/releases/download/v${K6_VERSION}/k6-v${K6_VERSION}-linux-$TARGETARCH.tar.gz k6-v${K6_VERSION}-linux-$TARGETARCH.tar.gz
RUN tar -xf k6-v${K6_VERSION}-linux-$TARGETARCH.tar.gz --strip-components 1 -C /usr/bin

FROM ubuntu:${UBUNTU_VERSION} AS latest

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=docker:dind /usr/local/bin /usr/local/bin

WORKDIR /vdp

ARG CACHE_DATE
RUN echo "VDP latest codebase cloned on ${CACHE_DATE}"

RUN git clone -b heiru/ins-777-otel-trace-entrypoint-in-api-gateway https://github.com/instill-ai/api-gateway.git
RUN git clone -b heiru/ins-526-implement-opentelemetry-in-pipeline https://github.com/instill-ai/pipeline-backend.git
RUN git clone -b heiru/ins-525-implement-opentelemetry-in-connector-backend https://github.com/instill-ai/connector-backend.git
RUN git clone -b heiru/ins-524-implement-opentelemetry-in-model-backend https://github.com/instill-ai/model-backend.git
RUN git clone https://github.com/instill-ai/mgmt-backend.git
RUN git clone https://github.com/instill-ai/controller.git
RUN git clone https://github.com/instill-ai/console.git

FROM ubuntu:${UBUNTU_VERSION} AS release

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=docker:dind /usr/local/bin /usr/local/bin

WORKDIR /vdp

ARG CACHE_DATE
RUN echo "VDP release codebase cloned on ${CACHE_DATE}"

ARG API_GATEWAY_VERSION PIPELINE_BACKEND_VERSION CONNECTOR_BACKEND_VERSION MODEL_BACKEND_VERSION MGMT_BACKEND_VERSION CONTROLLER_VERSION CONSOLE_VERSION
RUN git clone -b v${API_GATEWAY_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/api-gateway.git
RUN git clone -b v${PIPELINE_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/pipeline-backend.git
RUN git clone -b v${CONNECTOR_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/connector-backend.git
RUN git clone -b v${MODEL_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/model-backend.git
RUN git clone -b v${MGMT_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/mgmt-backend.git
RUN git clone -b v${CONTROLLER_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/controller.git
RUN git clone -b v${CONSOLE_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/console.git
