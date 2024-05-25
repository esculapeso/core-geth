#!/bin/bash

# Function to unmount and remove directory if not in use
unmount_and_remove_directory() {
  if mountpoint -q "$1"; then
    echo "Unmounting and removing directory $1"
    sudo umount "$1"
    if [ $? -ne 0 ]; then
      echo "Failed to unmount $1. Exiting."
      exit 1
    fi
    rm -rf "$1"
    echo "Directory $1 unmounted and removed successfully"
  else
    echo "Directory $1 is not a mount point. Removing directory."
    rm -rf "$1"
  fi
}

# Check for any geth processes (ensure not running)
if pgrep geth; then
  echo "Geth process is running. Exiting."
  exit 1
else
  echo "No Geth process found. Continuing."
fi

# Unmount and remove existing data directory if it exists
unmount_and_remove_directory /home/gethuser/.esa

# Ensure the directory is removed before proceeding
if [ -d "/home/gethuser/.esa" ]; then
  echo "Failed to remove /home/gethuser/.esa directory."
  exit 1
fi

# Initialize the Geth node with the genesis file
/home/gethuser/core-geth/build/bin/geth --datadir=/home/gethuser/.esa init /home/gethuser/core-geth/esa_genesis.json

# Check if initialization was successful
if [ $? -ne 0 ]; then
  echo "Failed to initialize Geth with genesis file."
  exit 1
fi

# Start the Geth node with the specified parameters
exec /home/gethuser/core-geth/build/bin/geth \
  --http \
  --http.addr "0.0.0.0" \
  --http.port 8545 \
  --http.api "eth,web3,personal,net" \
  --http.corsdomain "*" \
  --ipcpath /home/gethuser/.esa/geth.ipc \
  --datadir /home/gethuser/.esa \
  ${IP:+--nat extip:"$IP"} \
  ${BOOTNODES:+--bootnodes "$BOOTNODES"}
