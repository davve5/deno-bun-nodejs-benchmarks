FROM alpine:latest as base

# Install common dependencies
RUN apk add --no-cache git nodejs npm curl unzip

# Install Bun directly from GitHub releases
RUN curl -fsSL https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64.zip -o bun.zip && \
    mkdir -p /usr/local/bun && \
    unzip bun.zip -d /usr/local/bun && \
    ln -s /usr/local/bun/bun-linux-x64/bun /usr/local/bin/bun && \
    rm bun.zip
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community deno

# Clone the repository
WORKDIR /app
RUN git clone https://github.com/davve5/runtime-comparison-node-deno-bun.git .

# Show directory structure for debugging

# Make benchmark script executable
RUN chmod +x /benchmark/run-benchmarks.sh

# Stage 1: 250MHz, 500MB
FROM base as benchmark_250mhz_500mb
ENV CPU_LIMIT=0.25
ENV MEM_LIMIT=500MB
ENV BENCHMARK_NAME="250MHz_500MB"
WORKDIR /benchmark
CMD echo "Running benchmark with ${CPU_LIMIT} CPUs and ${MEM_LIMIT} memory" && \
    ./run-benchmarks.sh > /test_results/results_${BENCHMARK_NAME}.log 2>&1

# Stage 2: 500MHz, 500MB
FROM base as benchmark_500mhz_500mb
ENV CPU_LIMIT=0.5
ENV MEM_LIMIT=500MB
ENV BENCHMARK_NAME="500MHz_500MB"
WORKDIR /benchmark
CMD echo "Running benchmark with ${CPU_LIMIT} CPUs and ${MEM_LIMIT} memory" && \
    ./run-benchmarks.sh > /test_results/results_${BENCHMARK_NAME}.log 2>&1

# Stage 3: 1GHz, 1GB
FROM base as benchmark_1ghz_1gb
ENV CPU_LIMIT=1.0
ENV MEM_LIMIT=1GB
ENV BENCHMARK_NAME="1GHz_1GB"
WORKDIR /benchmark
CMD echo "Running benchmark with ${CPU_LIMIT} CPUs and ${MEM_LIMIT} memory" && \
    ./run-benchmarks.sh > /test_results/results_${BENCHMARK_NAME}.log 2>&1

# Stage 4: 2GHz, 2GB
FROM base as benchmark_2ghz_2gb
ENV CPU_LIMIT=2.0
ENV MEM_LIMIT=2GB
ENV BENCHMARK_NAME="2GHz_2GB"
WORKDIR /benchmark
CMD echo "Running benchmark with ${CPU_LIMIT} CPUs and ${MEM_LIMIT} memory" && \
    ./run-benchmarks.sh > /test_results/results_${BENCHMARK_NAME}.log 2>&1

# Stage 5: 2GHz, 5GB
FROM base as benchmark_2ghz_5gb
ENV CPU_LIMIT=2.0
ENV MEM_LIMIT=5GB
ENV BENCHMARK_NAME="2GHz_5GB"
WORKDIR /benchmark
CMD echo "Running benchmark with ${CPU_LIMIT} CPUs and ${MEM_LIMIT} memory" && \
    ./run-benchmarks.sh > /test_results/results_${BENCHMARK_NAME}.log 2>&1