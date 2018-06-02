## Rails

You'll need NodeJS and Yarn.

```sh
git clone https://github.com/Sjors/matreon.git
cd matreon
bundle install --without development:test
yarn install
```

Create a `.env` file with:

```
NETWORK=testnet # or "bitcoin" for mainnet
LIGHTNING_CHARGE_API_TOKEN=1234
FROM_EMAIL="you@example.com"
BUGS_TO="bugs@example.com"
SECRET_KEY_BASE=`hexdump -n 64 -e '16/4 "%08x" 1 "\n"' /dev/random`
DEVISE_SECRET_KEY=`hexdump -n 64 -e '16/4 "%08x" 1 "\n"' /dev/random`
HOSTNAME=http://localhost
SMTP_HOST=...
SMTP_USERNAME=...
SMTP_PASSWORD=...
RAILS_ENV=production
NODE_ENV=production
```

Load them:

```sh
set -a
. .env
set +a
```

Migrate the database:

```sh
bundle exec rake db:migrate
```

Start the server:

```sh
rake assets:precompile
bundle exec puma -C config/puma.rb -p 3000
```

Visit [localhost](http://localhost:3000/).

## Cron jobs

Cron jobs are used to send out monthly invoices, etc, see [example for AWS](/vendor/AWS/crontab-matreon). Tasks should be run by the Rails user. 

## Nginx

You may want to use Nginx as well, in which case leave out `-p 3000`.
