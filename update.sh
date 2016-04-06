#!/usr/bin/env bash

set -x

# Install python requirements
sudo pip install --requirement requirements.txt

# # Install node requirements
# sudo npm install --global

# Run migrations
sentry upgrade

# Collect static files for nginx to serve
sentry django collectstatic --noinput

# Set up the upstart processes
sudo honcho export upstart /etc/init \
	--app sentry \
	--user nobody \
	--procfile Procfile-vm

# Set up nginx
# https://docs.getsentry.com/on-premise/server/installation/#proxying-with-nginx
cat > /etc/nginx/sites-available/sentry <<EOF
location / {
  proxy_pass         unix:/tmp/sentry.sock;
  proxy_redirect     off;

  proxy_set_header   Host              $host;
  proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
  proxy_set_header   X-Forwarded-Proto $scheme;
}
EOF
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/sentry /etc/nginx/sites-enabled/sentry