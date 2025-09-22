FROM rust:1.90 as builder


RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    pkg-config \
    libgtk-3-dev \
    libcairo2-dev \
    libglib2.0-dev \
    libgdk-pixbuf2.0-dev \
    libpango1.0-dev \
    libatk1.0-dev \
    libx11-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


WORKDIR /app

# Copy source and build the binary
COPY src-tauri /app/src-tauri
RUN cd src-tauri && cargo build --release

# ---

FROM debian:trixie-slim

WORKDIR /app

# Copy the built binary
COPY --from=builder /app/src-tauri/target/release/chiral-network /usr/local/bin/chiral-network

EXPOSE 4001 
EXPOSE 8545

ENV ENABLE_GETH=""
  
# Add --enable-geth if ENABLE_GETH is set to true
ENTRYPOINT ["/bin/sh", "-c", 'exec /usr/local/bin/chiral-network --headless --dht-port 4001 --show-multiaddr ${ENABLE_GETH:+--enable-geth}']