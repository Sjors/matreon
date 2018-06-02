## Prerequisites

Pending a mock, you'll need to have access to a Lightning Charge installation.

## Tools

Install [RVM](https://rvm.io) (Ruby Version Manager) and `rvm install` the right [Ruby version](Gemfile#L1). Install [NVM](https://github.com/creationix/nvm#install-script) (Node Version Manager) and `nvm install` the right NodeJS version, see `{engines: {node: ...}}` in [package.json](package.json).

If you're working on the client side javascript, install [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi) and [Redux Developer Tools](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd) for Chrome.

If you're working on the Rails application, you can trigger system notifications on macOS during test runs:

```sh
brew install terminal-notifier
``` 

If you're working on the AWS deployment script, see instructions for [programatic deploys](/vendor/AWS#deploy).

## Compile Rails & ReactJS application

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

Use Guard to automatically run tests each time you change something.

To trigger invoice emails (delivered to `tmp/mails/[address]`), run: `rake invoices:process`
