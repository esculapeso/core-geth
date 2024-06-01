# Use the official Golang image as the base image
FROM golang:1.15-alpine as builder

# Install necessary tools and dependencies
RUN apk add --no-cache make gcc musl-dev linux-headers git

# Clone the Core Geth repository and build it
RUN git clone https://github.com/esculapeso/core-geth.git /root/core-geth && \
    cd /root/core-geth && \
    git checkout esa_new_network && \
    make geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

# Install necessary runtime dependencies
RUN apk add --no-cache ca-certificates

# Copy the built geth binary from the builder stage
COPY --from=builder /core-geth/build/bin/geth /usr/local/bin/

# Copy the entrypoint script into the container
COPY entrypoint.sh /root/core-geth/entrypoint.sh
RUN chmod +x /root/core-geth/entrypoint.sh

# Set the working directory
WORKDIR /root/core-geth

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/root/core-geth/entrypoint.sh"]
