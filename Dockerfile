# -------- Stage 1: Builder --------
FROM ubuntu:22.04 AS builder

# Install build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libgmp3-dev \
    libprocps-dev \
    libboost-all-dev \
    libssl-dev \
    libsodium-dev \
    libsimdjson-dev && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /app

# Copy libiop source
COPY libiop libiop

# Install Rust (required for Circom v2)

RUN apt-get update && apt-get install -y curl ca-certificates && \
    curl https://sh.rustup.rs -sSf | bash -s -- -y --profile minimal

ENV PATH="/root/.cargo/bin:${PATH}"

# Install Circom v2
RUN git clone https://github.com/iden3/circom.git && \
    cd circom && \
    cargo build --release

# Build ligero for goldilocks
WORKDIR /app/libiop
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBENCHMARK_ENABLE_TESTING=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && \
    make -j

# Build ligero for BN254
WORKDIR /app/libiop
RUN mkdir build_BN254 && cd build_BN254 && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBENCHMARK_ENABLE_TESTING=OFF -DUSE_BN254=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && \
    make -j

# -------- Stage 2: Runtime --------
FROM ubuntu:22.04

# Minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    python3 \
    libgmp3-dev \
    libprocps-dev \
    libboost-all-dev \
    libssl-dev \
    libsodium-dev \
    libsimdjson-dev

# Install snarkjs
RUN npm install -g snarkjs

WORKDIR /app

# Copy Circom binary from builder
COPY --from=builder /app/circom/target/release/circom /usr/local/bin/circom

# Copy the built ligero binary
COPY --from=builder /app/libiop/build/main/ligero /app/ligero
COPY --from=builder /app/libiop/build_BN254/main/ligero /app/ligero_BN254

# Copy circom
COPY circom circom

# Default entrypoint (can override)
ENTRYPOINT ["bash"]