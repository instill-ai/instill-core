FROM golang:1.17.2 AS builder

WORKDIR /go/src
COPY . /go/src

RUN go get -d -v ./...

RUN --mount=type=cache,target=/root/.cache/go-build go build -o /pipeline-workers ./cmd/

FROM gcr.io/distroless/base AS runtime

WORKDIR /pipeline-workers

COPY --from=builder /pipeline-workers ./
COPY --from=builder /go/src/configs ./configs

ENTRYPOINT ["./pipeline-workers"]
