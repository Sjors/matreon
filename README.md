# Matreon [![Build Status](https://travis-ci.org/Sjors/matreon.svg?branch=master)](https://travis-ci.org/Sjors/matreon) [![Coverage Status](https://coveralls.io/repos/github/Sjors/matreon/badge.svg?branch=master)](https://coveralls.io/github/Sjors/matreon?branch=master)


Current status: extremely experimental!

Live instance: [matreon.sprovoost.nl](https://matreon.sprovoost.nl/)

## Prerequisites

You need to run [c-lightning](https://github.com/ElementsProject/lightning) and [Lightning Charge](https://github.com/ElementsProject/lightning-charge) somewhere.

## Deploy with Docker

Install [Docker](https://docs.docker.com/install/).

Work in progress. For now it just launches `bitcoind` and syncs the node:

Create a directory to store the blockchain, wallet info, etc:

```sh
mkdir matreon-vol
pushd matreon-vol
mkdir bitcoin
popd
```

Build the docker image:

```sh
docker build docker -t matreon:latest
```

Run docker:

```sh
docker run --rm --name matreon -v $(PWD)/matreon-vol/bitcoin:/home/bitcoin/.bitcoin  -it matreon:latest -printtoconsole
```

## Deploy to Heroku

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
