# Use the official CentOS 7 image as the base image
FROM centos:7

# Install necessary tools and dependencies
RUN yum install -y epel-release centos-release-scl && \
    yum groupinstall -y "Development Tools" && \
    yum install -y devtoolset-7 binutils libtool autoconf automake golang git sudo

# Enable devtoolset-7
RUN echo "source /opt/rh/devtoolset-7/enable" >> /etc/profile.d/devtoolset-7.sh
ENV PATH="/opt/rh/devtoolset-7/root/usr/bin:${PATH}"

# Set up environment variables for Go
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"

# Clone the Core Geth repository and build it
RUN git clone https://github.com/esculapeso/core-geth.git /root/core-geth && \
    cd /root/core-geth && \
    git checkout esa_new_network && \
    make all

# Copy the entrypoint script into the container
COPY entrypoint.sh /root/core-geth/entrypoint.sh
RUN chmod +x /root/core-geth/entrypoint.sh

# Remove any unnecessary files
RUN find /root/core-geth -type f \( \
    -name "*.md" -o \
    -name "COPYING*" -o \
    -name "Dockerfile*" -o \
    -name "appveyor.yml" -o \
    -name "circle.yml" -o \
    -name "Jenkinsfile" -o \
    -name ".travis.yml" -o \
    -name "*.yml" -o \
    -name "*.txt" -o \
    -name "*.key" \) -delete

# Set the working directory
WORKDIR /root/core-geth

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/root/core-geth/entrypoint.sh"]
