# Matreon [![Build Status](https://travis-ci.org/Sjors/matreon.svg?branch=master)](https://travis-ci.org/Sjors/matreon) [![Coverage Status](https://coveralls.io/repos/github/Sjors/matreon/badge.svg?branch=master)](https://coveralls.io/github/Sjors/matreon?branch=master)


Current status: extremely experimental!

Live instance: [matreon.sprovoost.nl](https://matreon.sprovoost.nl/)

## Deploy to AWS

This is currently quite brittle and not very secure.

Deploy latest release: [![Matreon.Template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/images/cloudformation-launch-stack-button.png)](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?stackName=Matreon&templateURL=https:%2F%2Fs3.eu-central-1.amazonaws.com%2Fmatreon%2FMatreon.Template)

Or install the Amazon CloudFormation template by downloading [Matreon.Template](https://raw.githubusercontent.com/Sjors/matreon/master/vendor/AWS/Matreon.Template) and then uploading it on the [CloudFormation stack creation page](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1&stackName=Matreon#/stacks/new).

Fill out the form, click next a few times and then wait while it installs applications and downloads the blockchain. After about half an hour on testnet or four hours on mainnet the status should change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`.

In order to download the blockchain in a reasonable amount of time, a high performance machine was used. Similar to how a sea squirt eats its own brain when it finds a place to stay and no longer needs to swim, you should downgrade to a cheaper machine once the blockchain has been downloaded.

Click on the stack name in the [Cloud Formation home]( https://eu-central-1.console.aws.amazon.com/cloudformation/home) and look under resources. Click the link next to WebServer (i-xxxxxxx) which takes you to the EC2 instance management page (you may need to refresh the page first).

The machine state should be `stopped`, but if it isn't click on the Actions button -> Instance State -> Stop.

Once it's stopped, click on the Actions button -> Instance Settings -> Change nstance type and choose `t2.small`. Finally, start the instance. A few minutes later your Matreon should be ready to go!

To monitor logs of the docker containers: `journalctl -u docker-compose-matreon -f`

This [blog post](https://medium.com/provoost-on-crypto/bitcoin-core-lightning-rails-on-aws-ad3bd45b11e0) explains the steps in more detail.

## Deploy elsewhere using Docker

Install [Docker](https://docs.docker.com/install/).

Create a directory to store the blockchain, wallet info, etc:

```sh
mkdir matreon-vol
mkdir matreon-vol/lightning
mkdir matreon-vol/charge
mkdir matreon-vol/pg
```

We use Docker Compose to combine a number of containers. Hardcoding a [Docker image checksum](https://docs.docker.com/engine/security/trust/content_trust/#content-trust-operations-and-keys) doesn't prove how the image was built, so to minimize trust, we have to build the containers locally.

However for performance critical stuff like Bitcoin Core, it's better to just install
these manually.

### Bitcoin Core

Download the latest release from [bitcoincore.org](https://bitcoincore.org/en/download/).

You can either use the GUI or `bitcoind`, as long as you provide RPC access. Create a `bitcoin.conf` file:

```
testnet=1
rpcallowip=0.0.0.0/0
server=1
disablewallet=1
```

### C-Lightning

See [installation instructions](https://github.com/ElementsProject/lightning/blob/master/doc/INSTALL.md).

### Container 3 - Lightning Charge

```sh
git clone https://github.com/ElementsProject/lightning-charge
docker build lightning-charge -t charge:latest
```

### Container 4 - Postgres

We're trusting the upstream image for now.

### Container 5 - Rails & Matreon

```sh
git clone https://github.com/Sjors/matreon.git
```

Once the container is running (see below), you can open a Rails console:

```sh
docker-compose run web rails console
```

Or view the server logs:

```sh
docker logs -f matreon_web_1
```

### Docker Compose

From the Matreon project directory:

```sh
export NETWORK=testnet # or "bitcoin" for mainnet
export DATADIR=~/matreon-vol/bitcoin
export LIGHTNING_CHARGE_API_TOKEN=1234
export FROM_EMAIL="you@example.com"
export BUGS_TO="bugs@example.com"
export SECRET_KEY_BASE=`hexdump -n 64 -e '16/4 "%08x" 1 "\n"' /dev/random`
export DEVISE_SECRET_KEY=`hexdump -n 64 -e '16/4 "%08x" 1 "\n"' /dev/random`
export HOSTNAME=http://localhost
export SMTP_HOST=...
export SMTP_USERNAME=...
export SMTP_PASSWORD=...
docker-compose build
docker-compose up -d
```

Migrate the database:

```sh
docker-compose run web rake db:migrate
```

Visit [localhost](http://localhost/).

To shut everything down

```
docker-compose down
```

### Cron jobs

Add the following cron jobs (`crontab -e`):

```sh
0 * * * * cd /usr/local/src/matreon && /usr/local/bin/docker-compose run web rake invoices:process
0 * * * * cd /usr/local/src/matreon && /usr/local/bin/docker-compose run web rake podcast:fetch
```

## Deploy to Heroku

### Prerequisites

You need to run [c-lightning](https://github.com/ElementsProject/lightning) and [Lightning Charge](https://github.com/ElementsProject/lightning-charge) somewhere.

### Heroku

Create a new Heroku app `app-name` and add the Sendgrid Add-On.

Clone this repo and:

```sh
heroku git:remote -a app-name
heroku config:add HOSTNAME=app-name.herokuapp.com # Must be HTTPS
heroku config:add LIGHTNING_CHARGE_URL=https://charge.example.com
heroku config:add LIGHTNING_CHARGE_API_TOKEN=...
heroku config:add FROM_EMAIL='"My Matreon" <you@example.com>'
heroku config:add BUGS_TO=bugs@example.com
git push heroku
heroku run db:migrate
```

To send out monthly emails and monitor payments, install the `scheduler` addon:

```
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

Click "Add a new job", enter `rake invoices:process` and press `Save`. Set frequency to hourly to retry in case of failure.

It's free to use your own domain with Heroku. SSL for your own domain is also easy to setup, but not free.

## Podcast RSS feed

In order to provide a podcast feed for your supporters, you need to configure
some channel metadata and provide a URL of an existing podcast RSS feed. Uploading 
episodes directly isn't supported yet, see [#25](https://github.com/Sjors/matreon/issues/25).

```sh
heroku config:add PODCAST=1
heroku config:add PODCAST_TITLE='Sjorsnado Podcast'
heroku config:add PODCAST_IMAGE=https://example.com/podcast.png
heroku config:add PODCAST_URL=https://example.com/podcast.rss
```

In Heroku click "Ad a new job", enter `rake podcast:fetch` and press `Save`. Suggested frequency is hourly.

## Development

Install [RVM](https://rvm.io) (Ruby Version Manager) and `rvm install` the right [Ruby version](Gemfile#L1). Install [NVM](https://github.com/creationix/nvm#install-script) (Node Version Manager) and `nvm install` the right NodeJS version, see `{engines: {node: ...}}` in [package.json](package.json).

Clone this repo and create a file `.env` with:

```
LIGHTNING_CHARGE_URL=...
LIGHTNING_CHARGE_API_TOKEN=...
FROM_EMAIL='"My Matreon" <you@example.com>'
```

Install dependencies, create database and start server:

```sh
gem install foreman
bundle install --without production
rake db:migrate
foreman start -f Procfile.dev-server
```

Use Guard to automatically run tests each time you change something. To trigger
a system notification on macOS:

```sh
brew install terminal-notifier
``` 

Install [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi) and [Redux Developer Tools](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd) for Chrome.

To trigger invoice emails (delivered to `tmp/mails/[address]`), run: `rake invoices:process`
