# Use the official Golang image as the base image
FROM golang:1.17

# Set the environment variables
ENV GETH_REPO https://github.com/etclabscore/core-geth.git
ENV GETH_BRANCH release/v1.13.0

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y build-essential libgmp3-dev

# Clone the Core Geth repository and build it
RUN git clone https://github.com/esculapeso/core-geth.git /root/core-geth && \
    cd /root/core-geth && \
    git checkout esa_new_network && \
    make geth
# Copy the entrypoint script into the container
COPY entrypoint.sh /root/core-geth/entrypoint.sh
RUN chmod +x /root/core-geth/entrypoint.sh
# Set the working directory
WORKDIR /root/core-geth
# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp
# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/root/core-geth/entrypoint.sh"]