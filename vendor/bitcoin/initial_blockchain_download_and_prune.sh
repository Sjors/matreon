#!/bin/bash

# Skip if no big disk is available:
if [ ! -L /home/bitcoin/big-disk ]; then
  touch /home/bitcoin/.ibd_service_finished
  exit 0
fi

# Skip if IBD has already been done:
if [ -f /home/bitcoin/.ibd_service_finished ]; then exit 0; fi

# /home/bitcoin/big-disk needs to be symlink pointing a big drive
export OPTS="-conf=/etc/bitcoin/bitcoin.conf -datadir=/home/bitcoin/big-disk"

# Start bitcoind with manual pruning and a large enough dbcache.
echo "Start bitcoind as a daemon..."
bitcoind $OPTS -dbcache=20000 -prune=1 -daemon

set -o pipefail
while sleep 60
do
  if bitcoin-cli $OPTS getblockchaininfo  | jq -e '.initialblockdownload==false'; then
    # Prune to slightly before (a lot on testnet) the first Lightning block:
    bitcoin-cli $OPTS pruneblockchain 504500
    bitcoin-cli $OPTS stop
    while sleep 10 
    do # Wait for shutdown
      if [ ! -f /home/bitcoin/big-disk/bitcoind.pid ] && [ ! -f /home/bitcoin/big-disk/testnet3/bitcoind.pid ]; then
        break
      fi
    done
    break
  fi
done

# Move pruned blocks to /home/bitcoin/.bitcoin
if ! cat /etc/bitcoin/bitcoin.conf | grep '^testnet=1'; then
  mv /home/bitcoin/big-disk/blocks/*.dat /home/bitcoin/.bitcoin/blocks
  mv /home/bitcoin/big-disk/blocks/index/* /home/bitcoin/.bitcoin/blocks/index
  mv /home/bitcoin/big-disk/chainstate /home/bitcoin/.bitcoin
else
  mv /home/bitcoin/big-disk/testnet3/blocks/*.dat /home/bitcoin/.bitcoin/testnet3/blocks
  mv /home/bitcoin/big-disk/testnet3/blocks/index/* /home/bitcoin/.bitcoin/testnet3/blocks/index
  mv /home/bitcoin/big-disk/testnet3/chainstate /home/bitcoin/.bitcoin/testnet3
fi

# Remove big disk symlink
rm /home/bitcoin/big-disk

# Mark IBD as done:
touch /home/bitcoin/.ibd_service_finished
touch /home/bitcoin/.ibd_service_requests_shutdown
