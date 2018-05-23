 #!/bin/bash
while sleep 120
do
  if docker-compose exec -T bitcoind bitcoin-cli -datadir=/home/bitcoin/.bitcoin getblocktemplate; then
    export BLOCK_COUNT=`docker-compose exec -T bitcoind bitcoin-cli -datadir=/home/bitcoin/.bitcoin getblockcount`
    docker-compose exec -T bitcoind bitcoin-cli -datadir=/home/bitcoin/.bitcoin pruneblockchain $BLOCK_COUNT
    docker-compose down
    mv /mnt/ramdisk/bitcoin/* /matreon_data/bitcoin
    break
  fi
done
