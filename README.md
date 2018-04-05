# Matreon

Current status: vaporware!

## Prerequisites

You need to run [c-lightning](https://github.com/ElementsProject/lightning) and [Lightning Charge](https://github.com/ElementsProject/lightning-charge) somewhere.

## Deploy to Heroku

Assuming you have an account, clone the repository.

```
heroku apps:create
heroku config:add LIGHTNING_CHARGE_URL=https://charge.example.com
git push heroku
heroku run db:migrate
```

It's free to use your own domain with Heroku. SSL for your own domain is also easy to setup, but not free.

## Development

```sh
bundle install --without production
```
