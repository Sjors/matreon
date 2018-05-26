#!/bin/bash
set -o pipefail
export OPTS="-conf=/etc/bitcoin/bitcoin.conf -datadir=/mnt/ssd/bitcoin"
while sleep 60
do
  if bitcoin-cli $OPTS getblockchaininfo  | jq -e '.initialblockdownload==false'; then
    export BLOCK_COUNT=`bitcoin-cli $OPTS getblockcount`
    bitcoin-cli $OPTS pruneblockchain $BLOCK_COUNT
    bitcoin-cli $OPTS stop
    while sleep 10 
    do # Wait for shutdown
      if [ ! -f /mnt/ssd/bitcoin/bitcoind.pid ] && [ ! -f /mnt/ssd/bitcoin/testnet3/bitcoind.pid ]; then
        break
      fi
    done
    break
  fi
done
