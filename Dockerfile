FROM debian:bullseye-slim as base

# Install common dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (recommended LTS version)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version \
    # Install a compatible npm version
    && npm install -g npm@10.2.4

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh \
    && ln -s /usr/local/bin/deno /usr/bin/deno \
    && deno --version

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -s /root/.bun/bin/bun /usr/local/bin/bun \
    && bun --version

# Add all runtimes to PATH
ENV PATH="/usr/local/bin:/root/.bun/bin:/usr/bin:${PATH}"

# Set up working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN npm install

# Create directory for results
RUN mkdir -p /test_results

# Verify all runtimes are properly installed and working
RUN echo "Verifying Node.js installation:" && node --version && npm --version \
    && echo "Verifying Deno installation:" && deno --version \
    && echo "Verifying Bun installation:" && bun --version

# Images with different resource constraints
FROM base as benchmark_250mhz_500mb
CMD ["bash", "./run-benchmarks.sh"]

FROM base as benchmark_500mhz_500mb
CMD ["bash", "./run-benchmarks.sh"]

FROM base as benchmark_1ghz_1gb
CMD ["bash", "./run-benchmarks.sh"]

FROM base as benchmark_2ghz_2gb
CMD ["bash", "./run-benchmarks.sh"]

FROM base as benchmark_2ghz_5gb
CMD ["bash", "./run-benchmarks.sh"]