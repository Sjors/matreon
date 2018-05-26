#!/bin/bash
cd /tmp
export BITCOIN_VERSION=0.16.0
export BITCOIN_URL=https://bitcoincore.org/bin/bitcoin-core-0.16.0/bitcoin-0.16.0-x86_64-linux-gnu.tar.gz
export BITCOIN_SHA256=e6322c69bcc974a29e6a715e0ecb8799d2d21691d683eeb8fef65fc5f6a66477
export BITCOIN_ASC_URL=https://bitcoincore.org/bin/bitcoin-core-0.16.0/SHA256SUMS.asc
export BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964
wget -qO bitcoin.tar.gz "$BITCOIN_URL"
echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
&& gpg --keyserver keyserver.ubuntu.com --recv-keys "$BITCOIN_PGP_KEY" \
&& wget -qO bitcoin.asc "$BITCOIN_ASC_URL" \
&& gpg --verify bitcoin.asc \
&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt
