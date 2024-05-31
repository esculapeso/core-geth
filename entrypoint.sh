#!/bin/bash

set -e

echo "Starting Geth with the following parameters:"
echo "IP: $IP"
echo "BOOTNODES: $BOOTNODES"

# Path to the flag file
FLAG_FILE="/root/core-geth/initialized.flag"
GENESIS_FILE="/root/core-geth/esa_genesis.json"
UPDATED_GENESIS_FILE="/root/core-geth/updated_genesis.json"
KEYSTORE_DIR="/root/.esa/keystore"
PASSWORD_FILE="/root/core-geth/password.txt"

# Check if the necessary environment variable is set
if [ -z "$ACCOUNT_PASSWORD" ]; then
  echo "ACCOUNT_PASSWORD is not set. Aborting initialization."
  exit 1
fi

# Check if the initialization has already been done
if [ "$FIRST_NODE" = "true" ] && [ ! -f "$FLAG_FILE" ]; then
  echo "Initializing the first node with an account..."

  # Create the password file
  echo $ACCOUNT_PASSWORD > $PASSWORD_FILE
  chmod 600 $PASSWORD_FILE

  # Create a new account and capture the address
  ACCOUNT_ADDRESS=$(./build/bin/geth --datadir /root/.esa account new --password $PASSWORD_FILE | grep -oP '(?<=Address: \{).*(?=\})')

  # Update the genesis.json file with the new account address
  jq --arg address "$ACCOUNT_ADDRESS" '.alloc[$address] = { "balance": "0x2a" }' "$GENESIS_FILE" > "$UPDATED_GENESIS_FILE"

  # Use the updated genesis file
  GENESIS_FILE="$UPDATED_GENESIS_FILE"

  # Create the flag file to indicate initialization is done
  touch "$FLAG_FILE"
else
  echo "This node is not the first node or has already been initialized."
fi

# Initialize the Geth node with the genesis file
./build/bin/geth --datadir /root/.esa init "$GENESIS_FILE"

# Check if initialization was successful
if [ $? -ne 0 ]; then
  echo "Failed to initialize Geth with genesis file."
  exit 1
fi

# Start the Geth node with the specified parameters
exec ./build/bin/geth \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8545 \
  --http.api eth,web3,personal,net,miner \
  --http.corsdomain '*' \
  --ipcpath /root/.esa/geth.ipc \
  --datadir /root/.esa \
  --allow-insecure-unlock \
  --keystore $KEYSTORE_DIR \
  --networkid 83278 \
  ${IP:+--nat extip:"$IP"} \
  ${BOOTNODES:+--bootnodes "$BOOTNODES"}

echo "Entrypoint script completed successfully"
