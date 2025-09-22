FROM rust:1.90 as builder

WORKDIR /app

# Copy source and build the binary
COPY src-tauri /app/src-tauri
RUN cd src-tauri && cargo build --release

# ---

FROM debian:bullseye-slim

WORKDIR /app

# Copy the built binary
COPY --from=builder /app/src-tauri/target/release/chiral-network /usr/local/bin/chiral-network

EXPOSE 4001 
EXPOSE 8545

ENV ENABLE_GETH=""
  
# Add --enable-geth if ENABLE_GETH is set to true
ENTRYPOINT ["/bin/sh", "-c", 'exec /usr/local/bin/chiral-network --headless --dht-port 4001 --show-multiaddr ${ENABLE_GETH:+--enable-geth}']