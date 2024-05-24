# Build Geth in a stock Go builder container
FROM golang:1.15-alpine as builder

# Install necessary build tools
RUN apk add --no-cache make gcc musl-dev linux-headers git

# Set the working directory
WORKDIR /go-ethereum

# Add source code
ADD . .

# Build the Geth binary
RUN make geth

# Final stage: use a lightweight Alpine image for runtime
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache ca-certificates

# Set working directory
WORKDIR /root

# Copy the Geth binary from the builder stage
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Health check to ensure the Geth node is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:8545/ || exit 1

# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
