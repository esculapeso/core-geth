#!/bin/bash

if [ -z "$BOOTNODES" ]; then
  echo "BOOTNODES environment variable is not set"
  exit 1
fi

if [ -z "$IP" ]; then
  echo "IP environment variable is not set"
  exit 1
fi

# Initialize the Geth node with the genesis file
./build/bin/geth --datadir=/root/.esa init /root/core-geth/esa_genesis.json

# Start the Geth node with the specified parameters
exec ./build/bin/geth --http --http.addr "0.0.0.0" --http.port 8545 --http.api "eth,web3,personal,net" --http.corsdomain "*" --ipcpath /root/.esa/geth.ipc --datadir /root/.esa --bootnodes "$BOOTNODES" --nat extip:"$IP"
