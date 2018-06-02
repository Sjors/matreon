# Matreon [![Build Status](https://travis-ci.org/Sjors/matreon.svg?branch=master)](https://travis-ci.org/Sjors/matreon) [![Coverage Status](https://coveralls.io/repos/github/Sjors/matreon/badge.svg?branch=master)](https://coveralls.io/github/Sjors/matreon?branch=master)


Current status: extremely experimental!

Live instance: [matreon.sprovoost.nl](https://matreon.sprovoost.nl/)

## Deploy

This is currently quite brittle and not very secure.

The recommended approach is to use the following AWS CloudFormation template:

Deploy latest release: [![Matreon.Template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/images/cloudformation-launch-stack-button.png)](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?stackName=Matreon&templateURL=https:%2F%2Fs3.eu-central-1.amazonaws.com%2Fmatreon%2FMatreon.Template)

Or install the Amazon CloudFormation template by downloading [Matreon.Template](https://raw.githubusercontent.com/Sjors/matreon/master/vendor/AWS/Matreon.Template) and then uploading it on the [CloudFormation stack creation page](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1&stackName=Matreon#/stacks/new).

Alternatively you can also [deploy programatically](/vendor/AWS#deploy).

Fill out the form, click next a few times and then wait while it installs applications and downloads the blockchain. After about half an hour on testnet or four hours on mainnet the status should change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`.

In order to download the blockchain in a reasonable amount of time, a high performance machine was used. Similar to how a sea squirt eats its own brain when it finds a place to stay and no longer needs to swim, you should downgrade to a cheaper machine once the blockchain has been downloaded.

Click on the stack name in the [Cloud Formation home]( https://eu-central-1.console.aws.amazon.com/cloudformation/home) and look under resources. Click the link next to WebServer (i-xxxxxxx) which takes you to the EC2 instance management page (you may need to refresh the page first).

The machine state should be `stopped`, but if it isn't click on the Actions button -> Instance State -> Stop.

Once it's stopped, click on the Actions button -> Instance Settings -> Change nstance type and choose `t2.small`. Finally, start the instance. A few minutes later your Matreon should be ready to go!

This [blog post](https://medium.com/provoost-on-crypto/bitcoin-core-lightning-rails-on-aws-ad3bd45b11e0) explains the steps in more detail.

[INSTALL](/INSTALL.md) has instructions for Heroku and other platforms.

## Development

Pending a mock, you'll need to have access to a Lightning Charge installation.

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
