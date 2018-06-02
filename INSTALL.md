# Installation

The recommended method is AWS CloudFormation, as described in [README](/README#deploy-to-aws).

## AWS CloudFormation Template

Deploy latest release: [![Matreon.Template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/images/cloudformation-launch-stack-button.png)](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?stackName=Matreon&templateURL=https:%2F%2Fs3.eu-central-1.amazonaws.com%2Fmatreon%2FMatreon.Template)

Or download [Matreon.Template](vendor/AWS/Matreon.Template), upload it on the [CloudFormation stack creation page](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1&stackName=Matreon#/stacks/new).

In both cases, fill out the form and then follow instructions in [README](/README#deploy-to-aws).

You can also [deploy programatically](/vendor/AWS#deploy).

## Heroku

You need to run [c-lightning](https://github.com/ElementsProject/lightning) and [Lightning Charge](https://github.com/ElementsProject/lightning-charge) somewhere.

Create a new Heroku app `app-name` and add the Sendgrid Add-On.

Clone this repo and:

```sh
heroku git:remote -a app-name
heroku config:set HEROKU=true
heroku config:set HOSTNAME=https://app-name.herokuapp.com # Must be HTTPS
heroku config:set LIGHTNING_CHARGE_URL=https://charge.example.com
heroku config:set LIGHTNING_CHARGE_API_TOKEN=...
heroku config:set FROM_EMAIL='"My Matreon" <you@example.com>'
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

### Podcast RSS feed

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

## Other

Coming soon, hopefully: Ubuntu on [Orange Pi](https://github.com/Sjors/matreon/issues/53) and [Nanopi](https://github.com/Sjors/matreon/issues/54).

In addition to the sections below, I suggest studying the [AWS template](/vendor/AWS/Matreon.Template) and the various scripts in [/vendor](/vendor).

If you have Lightning Charge installed elsewhere, you can skip Bitcoin Core, C-Lightning and Lightning Charge. You'll need to put `LIGHTNING_CHARGE_URL=` into the Rails app.

* [Bitcoin Core instructions](/vendor/bitcoin#install)
* [C-Lightning instructions](/vendor/lightning#install)
* [Lightning Charge instructions](/vendor/charge#install)
* Install Postgres
* [Ruby on Rails, Puma & Nginx instructions](/vendor/www#install)
