#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Verifying Docker installation:${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed or not in PATH${NC}"
    exit 1
else
    echo -e "${GREEN}Docker is installed: $(docker --version)${NC}"
fi

echo -e "${BLUE}Verifying Docker Compose installation:${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed or not in PATH${NC}"
    exit 1
else
    echo -e "${GREEN}Docker Compose is installed: $(docker-compose --version)${NC}"
fi

echo -e "${BLUE}Building a minimal test container to verify runtimes:${NC}"
cat > Dockerfile.test << 'EOF'
FROM debian:bullseye-slim

# Install common dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh \
    && ln -s /usr/local/bin/deno /usr/bin/deno

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Add all runtimes to PATH
ENV PATH="/usr/local/bin:/root/.bun/bin:/usr/bin:${PATH}"

# Verify installations
CMD echo "Node.js: $(node --version)" && \
    echo "npm: $(npm --version)" && \
    echo "Deno: $(deno --version | head -n 1)" && \
    echo "Bun: $(bun --version)"
EOF

echo -e "${BLUE}Building test container...${NC}"
docker build -t benchmark-test -f Dockerfile.test .

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to build test container${NC}"
    exit 1
fi

echo -e "${BLUE}Running test container to verify runtimes:${NC}"
docker run --rm benchmark-test

if [ $? -eq 0 ]; then
    echo -e "${GREEN}All runtimes verified successfully!${NC}"
    echo -e "${GREEN}You can now run your benchmarks with:${NC}"
    echo -e "${BLUE}./run-docker-benchmarks.sh all${NC}"
else
    echo -e "${RED}Failed to verify runtimes${NC}"
    exit 1
fi

# Cleanup
rm Dockerfile.test