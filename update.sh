#!/usr/bin/env bash

# Starting the web service
# https://docs.getsentry.com/on-premise/server/installation/#starting-the-web-service
sentry start

# Starting the background workers
# https://docs.getsentry.com/on-premise/server/installation/#starting-background-workers
sentry celery worker

# Starting the cron process
# https://docs.getsentry.com/on-premise/server/installation/#starting-the-cron-process
sentry celery beat

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