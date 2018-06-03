#!/usr/bin/env bash
if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
  openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
fi

while sleep 60
do
  if dig $DOMAIN | grep $IP; then
    if /bin/certbot --nginx -m $EMAIL --agree-tos -n --domains $DOMAIN; then
      mv /etc/nginx/conf.d/https_upgrade.conf.disabled /etc/nginx/conf.d/https_upgrade.conf
      >/etc/nginx/conf.d/matreon/listen
      systemctl restart nginx
      exit 0
    else
      echo "Failed to register or install certificate, remove /home/certbot/.failed and restart the service to try again."
      touch /home/cert/.failed
      exit 1
    fi
  fi
  echo "DNS entry (A record for $DOMAIN to $IP) not found yet..."
done
exit 1
