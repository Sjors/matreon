 #!/bin/bash
while sleep 10
do
  if docker-compose exec -T bitcoind bitcoin-cli -datadir=/home/bitcoin/.bitcoin getblocktemplate; then
    break
  fi
done
