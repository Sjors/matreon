# Install

See [installation instructions](https://github.com/ElementsProject/lightning-charge#getting-started).

Generate a random API token: `hexdump -n 64 -e '16/4 "%08x" 1 "\n"' /dev/random`.

Run using `charged --API-TOKEN=...`.

To run as a service, create a user `charge` and put a `.env` file in `/home/charge`:

```sh
API_TOKEN=...
```

Copy `lightning-charge.service` to `/lib/systemd/system`, enable and start the service:

```sh
systemctl enable lightning-charge.service
systemctl start lightning-charge.service
```
