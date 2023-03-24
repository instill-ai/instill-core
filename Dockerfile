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

RUN git clone https://github.com/instill-ai/api-gateway.git api-gateway
RUN git clone https://github.com/instill-ai/pipeline-backend.git pipeline-backend
RUN git clone https://github.com/instill-ai/connector-backend.git connector-backend
RUN git clone https://github.com/instill-ai/model-backend.git model-backend
RUN git clone https://github.com/instill-ai/mgmt-backend.git mgmt-backend
RUN git clone https://github.com/instill-ai/console.git console
