#
# The golang:1.15 image is a copy of docker.io/library/golang:1.17 hosted in Quay to work around rate limits to
# Dockerhub:
#
# > docker pull golang:1.17.2
# > docker tag golang:1.17.2 quay.io/redhat-certification/golang:1.17.2
# > docker push quay.io/redhat-certification/golang:1.17.2
#
# To upgrade Go, then a new image should be pushed to Quay and updated below.
#
ARG quay_expiration=never
FROM quay.io/redhat-certification/golang:1.17.2 as build
ARG quay_expiration
WORKDIR /tmp/src

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go build -o ./out/chart-verifier main.go

FROM registry.access.redhat.com/ubi8/ubi-minimal
ARG quay_expiration
LABEL quay.expires-after=${quay_expiration}
COPY --from=build /tmp/src/out/chart-verifier /app/chart-verifier

WORKDIR /app

ENV PATH "$PATH:/app"

ENTRYPOINT ["/app/chart-verifier"]
