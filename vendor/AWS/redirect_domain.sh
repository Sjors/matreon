#!/usr/bin/env bash
while sleep 60
do
  if dig $DOMAIN | grep $IP; then
    mv /etc/nginx/conf.d/redirect_domain.conf.disabled /etc/nginx/conf.d/redirect_domain.conf
    systemctl restart nginx
    exit 0
  fi
  echo "DNS entry (A record for $DOMAIN to $IP) not found yet..."
done
exit 1
