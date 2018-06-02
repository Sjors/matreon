## Install

Download the latest release from [bitcoincore.org](https://bitcoincore.org/en/download/).

You can either use the GUI or `bitcoind`, as long as you provide RPC access. Create a `bitcoin.conf` file:

```
testnet=1
rpcallowip=0.0.0.0/0
server=1
disablewallet=1
```
