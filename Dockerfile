############################
# STEP 1 build executable binary
############################
FROM golang:1.13-alpine as builder

# Contact maintainer with any issues you encounter
MAINTAINER Agri Ardyan <aagriard@gmail.com>

LABEL stage=builder

# Input arguments
ARG buildVersion
ARG commitHash
ARG buildDate

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

# Set environment variables
ENV PATH /go/bin:$PATH
ENV GOPATH /go

# Create a new unprivileged user
RUN addgroup -S appgroup
RUN adduser -S appuser -G appgroup

# Cd into the api code directory
WORKDIR /go/src/kodiak.io/service-example

# Copy the local package files to the container's workspace.
ADD . /go/src/kodiak.io/service-example

# Set GO111MODULE=on variable to activate module support
ENV GO111MODULE on

# Chown the application directory to app user
# RUN chown -R appuser:appgroup /go/src/kodiak.io/service-example

RUN go mod vendor

# Install the api program
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-X 'main.Version=$buildVersion' -X 'main.CommitHash=$commitHash' -X 'main.BuildDate=$buildDate'" /go/src/kodiak.io/service-example
RUN echo $(ls -a /go/bin)

############################
# STEP 2 build a small image
############################
FROM alpine

# Import from builder.
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy our static executable
COPY --from=builder /go/src/kodiak.io/service-example /srv

# Service executable as entrypoint
ENTRYPOINT ["./srv/service-example"]

# Expose port 8080.
EXPOSE 8080

USER nobody