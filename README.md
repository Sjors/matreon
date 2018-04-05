# Matreon

Current status: vaporware!

## Prerequisites

You need to run [c-lightning](https://github.com/ElementsProject/lightning) and [Lightning Charge](https://github.com/ElementsProject/lightning-charge) somewhere.

## Deploy to Heroku

Create a new Heroku app `app-name` and add the Sendgrid Add-On.

Clone this repo and:

```sh
heroku git:remote -a app-name
heroku config:add ACTION_MAILER_DEFAULT_URL=https://app-name.herokuapp.com
heroku config:add LIGHTNING_CHARGE_URL=https://charge.example.com
heroku config:add FROM_EMAIL='"My Matreon" <you@example.com>'
git push heroku
heroku run db:migrate
```

It's free to use your own domain with Heroku. SSL for your own domain is also easy to setup, but not free.

## Development

Clone this repo and:

```sh
bundle install --without production
rake db:migrate
rails s
```
