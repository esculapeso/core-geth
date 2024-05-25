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
ENV GOPATH="/home/gethuser/go"

# Create a non-root user and assign permissions
RUN useradd -ms /bin/bash gethuser && \
    mkdir -p /home/gethuser/.esa && \
    chown -R gethuser:gethuser /home/gethuser && \
    chmod -R 755 /home/gethuser

# Allow gethuser to run necessary commands with sudo
RUN echo "gethuser ALL=(ALL) NOPASSWD: /bin/umount" >> /etc/sudoers

# Clone the Core Geth repository and build it as the non-root user
USER gethuser
WORKDIR /home/gethuser
RUN git clone https://github.com/esculapeso/core-geth.git && \
    cd core-geth && \
    git checkout esa_new_network && \
    make geth

# Switch back to the root user to copy the entrypoint script and set permissions
USER root
COPY entrypoint.sh /home/gethuser/core-geth/entrypoint.sh
RUN chmod +x /home/gethuser/core-geth/entrypoint.sh

# Change ownership back to the non-root user
RUN chown -R gethuser:gethuser /home/gethuser/core-geth

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Switch to non-root user
USER gethuser

# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/home/gethuser/core-geth/entrypoint.sh"]
