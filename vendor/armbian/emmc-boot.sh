#!/usr/bin/env bash

# Hacky way to check / guess if we booted from eMMC:
if cat /etc/fstab | grep ext4 | grep UUID; then
  echo "Not booted from eMMC"
  exit 1
fi

# Check if lightning charge secret is set:
if ! cat /home/charge/.env | grep API_TOKEN; then
  TOKEN=`uuidgen`
  echo "API_TOKEN=$TOKEN" >> /home/charge/.env
  echo "LIGHTNING_CHARGE_API_TOKEN=$TOKEN" >> /home/matreon/.env
fi

# Check if Rails secrets are set:
if ! cat /home/matreon/.env | grep SECRET_KEY_BASE; then
  echo "SECRET_KEY_BASE=`uuidgen`" >> /home/matreon/.env
fi

if ! cat /home/matreon/.env | grep DEVISE_SECRET_KEY; then
  echo "DEVISE_SECRET_KEY=`uuidgen`" >> /home/matreon/.env
fi

# Only do this once:
if [ ! -f /home/bitcoin/.ibd_service_finished ]; then
  # Enable and start systemd services:
  systemctl enable bitcoind.service
  systemctl enable bitcoind.path
  systemctl start bitcoind.path

  systemctl enable lightningd.service
  systemctl enable lightningd.path
  systemctl start lightningd.path

  systemctl enable lightning-charge.service
  systemctl enable lightning-charge.path
  systemctl start lightning-charge.path

  systemctl enable rails.service
  systemctl start rails.service

  # Enable crons
  crontab -u matreon /usr/local/src/matreon/vendor/AWS/crontab-matreon
  
  # Starts c-lightning and lightning charge. Lightning wallet and secrets are
  # created at first launch.
  touch /home/bitcoin/.ibd_service_finished
  
  # Configure nginx
  cp /usr/local/src/matreon/vendor/www/nginx.conf /etc/nginx/nginx.conf
  cp /usr/local/src/matreon/vendor/www/matreon.conf /etc/nginx/conf.d
  cp /usr/local/src/matreon/vendor/www/matreon/listen /etc/nginx/conf.d/matreon

  # TODO: if DOMAIN is configured...
  echo "server_name _;" /etc/nginx/conf.d/matreon/server_name
  # echo "server_name ${Domain};" /etc/nginx/conf.d/matreon/server_name

  # /etc/nginx/conf.d/redirect_domain.conf.disabled:
  #   content: !Sub |
  #     server {
  #       server_name *.amazonaws.com;
  #       listen 80;
  #       return 301 http://${Domain}$request_uri;
  #     }
  
  systemctl enable nginx
  systemctl start nginx
  
  # TODO: configure certbot

  #  cp /usr/local/src/matreon/vendor/www/https_upgrade.conf /etc/nginx/conf.d/https_upgrade.conf.disabled
  #  echo "`shuf -i 00-59 -n 1` `shuf -i 00-23 -n 1` * * * /usr/bin/certbot renew --quiet" >> /usr/local/src/matreon/vendor/AWS/crontab-matreon
fi
