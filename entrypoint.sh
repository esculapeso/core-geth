#!/bin/bash

echo "Starting Geth with the following parameters:"
echo "IP: $IP"
echo "BOOTNODES: $BOOTNODES"

# Path to the initialization keyfile
INIT_KEYFILE="/root/core-geth/init_keyfile.txt"
EXPECTED_SECRET="${INIT_SECRET}"

# Path to the flag file
FLAG_FILE="/root/core-geth/initialized.flag"
GENESIS_FILE="/root/core-geth/esa_genesis.json"
UPDATED_GENESIS_FILE="/root/core-geth/updated_genesis.json"

# Check if this node is the first node, if the keyfile exists, and if the flag file does not exist
if [ "$FIRST_NODE" = "true" ] && [ -f "$INIT_KEYFILE" ] && [ ! -f "$FLAG_FILE" ]; then
  # Read the secret from the keyfile
  ACTUAL_SECRET=$(cat "$INIT_KEYFILE")

  # Verify the secret
  if [ "$ACTUAL_SECRET" = "$EXPECTED_SECRET" ]; then
    echo "Initializing first node..."

    # Set the password for the new account
    ACCOUNT_PASSWORD="your-secure-password"
    PASSWORD_FILE="/root/core-geth/password.txt"

    # Create the password file
    echo $ACCOUNT_PASSWORD > $PASSWORD_FILE

    # Create a new account and capture the address
    ACCOUNT_ADDRESS=$(./build/bin/geth account new --password $PASSWORD_FILE --datadir /root/.esa | grep -oP '(?<=Address: \{).*(?=\})')

    # Update the genesis.json file with the new account address
    jq --arg address "$ACCOUNT_ADDRESS" '.alloc[$address] = { "balance": "0x2a" }' "$GENESIS_FILE" > "$UPDATED_GENESIS_FILE"

    # Use the updated genesis file
    GENESIS_FILE="$UPDATED_GENESIS_FILE"

    # Create the flag file to indicate initialization is done
    touch "$FLAG_FILE"
  else
    echo "Initialization keyfile secret does not match. Aborting initialization."
    exit 1
  fi
else
  echo "This node is not the first node, the initialization keyfile is missing, or the node has already been initialized."
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
  --networkid 83278 \
  ${IP:+--nat extip:"$IP"} \
  ${BOOTNODES:+--bootnodes "$BOOTNODES"}

echo "Entrypoint script completed successfully"
