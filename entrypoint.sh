#!/bin/bash

set -e
set -x  # Enable debug mode to show each command executed

echo "Starting Geth with the following parameters:"
echo "IP: $IP"
echo "BOOTNODES: $BOOTNODES"
echo "ACCOUNT_PASSWORD: '$ACCOUNT_PASSWORD'"

# Check Geth version
./build/bin/geth version 

# Flush output to ensure visibility
sync

# Path to the flag file
FLAG_FILE="/root/core-geth/initialized.flag"
GENESIS_FILE="/root/core-geth/esa_genesis.json"
UPDATED_GENESIS_FILE="/root/core-geth/updated_genesis.json"
KEYSTORE_DIR="/root/.esa/keystore"
PASSWORD_FILE="/root/core-geth/password.txt"

# Flush output to ensure visibility
sync

# Function to create a new account and return the address
create_account() {
  ACCOUNT_OUTPUT=$(timeout 30 ./build/bin/geth --verbosity 5 --datadir /root/.esa account new --password "$PASSWORD_FILE")
  echo "$ACCOUNT_OUTPUT"
  ACCOUNT_ADDRESS=$(echo "$ACCOUNT_OUTPUT" | grep -oP '(?<=Public address of the key:   ).*')
  echo "$ACCOUNT_ADDRESS"
}

# Check if the initialization has already been done
if [ "$FIRST_NODE" = "true" ] && [ ! -f "$FLAG_FILE" ]; then
  echo "Initializing the first node with accounts..."

  # Create the password file
  echo "$ACCOUNT_PASSWORD" > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"

  # Create three new Ethereum accounts
  ACCOUNT_ADDRESS_1=$(create_account)
  ACCOUNT_ADDRESS_2=$(create_account)
  ACCOUNT_ADDRESS_3=$(create_account)

  echo "New account addresses: $ACCOUNT_ADDRESS_1, $ACCOUNT_ADDRESS_2, $ACCOUNT_ADDRESS_3"

  # Update the genesis.json file with the new account addresses and balances
  jq --arg address1 "$ACCOUNT_ADDRESS_1" --arg balance1 "0x3B9ACA00" \
     --arg address2 "$ACCOUNT_ADDRESS_2" --arg balance2 "0x4F88B800" \
     --arg address3 "$ACCOUNT_ADDRESS_3" --arg balance3 "0x3B9ACA00" \
     '.alloc[$address1] = { "balance": $balance1 } |
      .alloc[$address2] = { "balance": $balance2 } |
      .alloc[$address3] = { "balance": $balance3 }' \
     "$GENESIS_FILE" > "$UPDATED_GENESIS_FILE"

  # Use the updated genesis file
  GENESIS_FILE="$UPDATED_GENESIS_FILE"

  # Create the flag file to indicate initialization is done
  touch "$FLAG_FILE"
else
  echo "This node is not the first node or has already been initialized."
fi

# Flush output to ensure visibility
sync

# Initialize the Geth node with the genesis file
./build/bin/geth --datadir /root/.esa init "$GENESIS_FILE"

# Check if initialization was successful
if [ $? -ne 0 ]; then
  echo "Failed to initialize Geth with genesis file. Stopping initialization."
  exit 1
fi

echo "Starting the Geth node now..."

# Flush output to ensure visibility
sync

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
  --keystore "$KEYSTORE_DIR" \
  --networkid 83278 \
  --verbosity 4 \
  ${IP:+--nat extip:"$IP"} \
  ${BOOTNODES:+--bootnodes "$BOOTNODES"}

echo "Entrypoint script completed successfully"
