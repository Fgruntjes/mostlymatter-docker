# Multi-stage build for Mostlymatter Docker image

# Stage 1: Download and verify the mostlymatter binary
FROM debian:bookworm-slim AS downloader

# Install necessary tools for downloading and verification
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set the mostlymatter version
ARG MOSTLYMATTER_VERSION=v10.6.1
ARG ARCH=amd64

# Download mostlymatter binary and verification files
WORKDIR /tmp/download
RUN wget -q https://packages.framasoft.org/projects/mostlymatter/mostlymatter-${ARCH}-${MOSTLYMATTER_VERSION} && \
    wget -q https://packages.framasoft.org/projects/mostlymatter/mostlymatter-${ARCH}-${MOSTLYMATTER_VERSION}.sha512 && \
    # Verify the SHA512 checksum
    sha512sum -c mostlymatter-${ARCH}-${MOSTLYMATTER_VERSION}.sha512 && \
    # Rename the binary to mostlymatter
    mv mostlymatter-${ARCH}-${MOSTLYMATTER_VERSION} mostlymatter && \
    # Make the binary executable
    chmod +x mostlymatter

# Stage 2: Create the final image
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    xmlsec1 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run mostlymatter
RUN groupadd -r mostlymatter && useradd -r -g mostlymatter mostlymatter

# Create necessary directories
RUN mkdir -p /opt/mostlymatter/bin /opt/mostlymatter/config /opt/mostlymatter/data /opt/mostlymatter/logs /opt/mostlymatter/plugins /opt/mostlymatter/client/plugins && \
    chown -R mostlymatter:mostlymatter /opt/mostlymatter

# Copy the binary from the downloader stage
COPY --from=downloader --chown=mostlymatter:mostlymatter /tmp/download/mostlymatter /opt/mostlymatter/bin/

# Set working directory
WORKDIR /opt/mostlymatter

# Set environment variables
ENV PATH="/opt/mostlymatter/bin:${PATH}" \
    MM_SERVICESETTINGS_LISTENADDRESS=":8065" \
    MM_LOGSETTINGS_FILELOCATION="/opt/mostlymatter/logs"

# Expose ports
# - 8065: API and HTTP/HTTPS traffic
# - 8064/8074/8075: Cluster ports for high availability
EXPOSE 8065 8064 8074 8075

# Set volume for data persistence
VOLUME ["/opt/mostlymatter/config", "/opt/mostlymatter/data", "/opt/mostlymatter/logs", "/opt/mostlymatter/plugins", "/opt/mostlymatter/client/plugins"]

# Switch to non-root user
USER mostlymatter

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

# Command to run
ENTRYPOINT ["/opt/mostlymatter/bin/mostlymatter"]
CMD ["server"]