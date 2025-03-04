FROM debian:bullseye-slim as base

# Install common dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh
ENV PATH="/root/.deno/bin:${PATH}"

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Set up working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN npm install

# Create directory for results
RUN mkdir -p /test_results

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