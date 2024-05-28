#!/bin/bash

echo "Starting Geth with the following parameters:"
echo "IP: $IP"
echo "BOOTNODES: $BOOTNODES"

# Initialize the Geth node with the genesis file
./build/bin/geth --datadir=/root/.esa init /root/core-geth/esa_genesis.json

# Check if initialization was successful
if [ $? -ne 0 ]; then
  echo "Failed to initialize Geth with genesis file."
  exit 1
fi

# Start the Geth node with the specified parameters
GETH_CMD="./build/bin/geth \
  --http \
  --http.addr "0.0.0.0" \
  --http.port 8545 \
  --http.api "eth,web3,personal,net,miner" \
  --http.corsdomain "*" \
  --ipcpath /root/.esa/geth.ipc \
  --datadir /root/.esa \
  --allow-insecure-unlock \
  --networkid 83278 \
  ${IP:+--nat extip:"$IP"} \
  ${BOOTNODES:+--bootnodes "$BOOTNODES"}"

echo "Executing: $GETH_CMD"

exec $GETH_CMD
