#!/usr/bin/env bash

set -x

# Set up the upstart processes
sudo honcho export upstart /etc/init \
	--app sentry \
	--user nobody

# Set up nginx
# https://docs.getsentry.com/on-premise/server/installation/#proxying-with-nginx
cat > /etc/nginx/sites-available/sentry <<EOF
location / {
  proxy_pass         http://localhost:9000;
  proxy_redirect     off;

  proxy_set_header   Host              $host;
  proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
  proxy_set_header   X-Forwarded-Proto $scheme;
}
EOF
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/sentry /etc/nginx/sites-enabled/sentry