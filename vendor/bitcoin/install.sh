#!/bin/bash
cd /tmp
export BITCOIN_VERSION=0.16.3
export BITCOIN_URL=https://bitcoincore.org/bin/bitcoin-core-0.16.3/bitcoin-0.16.3-x86_64-linux-gnu.tar.gz
export BITCOIN_SHA256=5d422a9d544742bc0df12427383f9c2517433ce7b58cf672b9a9b17c2ef51e4f
export BITCOIN_ASC_URL=https://bitcoincore.org/bin/bitcoin-core-0.16.3/SHA256SUMS.asc
export BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964
wget -qO bitcoin.tar.gz "$BITCOIN_URL"
echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
&& gpg --keyserver keyserver.ubuntu.com --recv-keys "$BITCOIN_PGP_KEY" \
&& wget -qO bitcoin.asc "$BITCOIN_ASC_URL" \
&& gpg --verify bitcoin.asc \
&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt
