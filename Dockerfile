FROM golang:1.17.2 AS builder

WORKDIR /go/src
COPY . /go/src

RUN go get -d -v ./...

RUN --mount=type=cache,target=/root/.cache/go-build go build -o /visual-data-preparation ./cmd/

FROM gcr.io/distroless/base AS runtime

WORKDIR /visual-data-preparation

COPY --from=builder /visual-data-preparation ./
COPY --from=builder /go/src/configs ./configs

ENTRYPOINT ["./visual-data-preparation"]
