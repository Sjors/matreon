## Permissions

Although the AWS template contains a user `certbot`, the actual Certbot, systemd
services and cron jobs using it all run as root. This is because they need to
modify nginx configuration files both to install the certificate and, more importantly,
to pass the domain control verification challenge.
