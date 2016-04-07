#!/usr/bin/env bash

set -x
SCRIPT_DIR=$(dirname $0)


# Install python requirements
sudo pip install --requirement requirements.txt

# # Install node requirements
# sudo npm install --global

# Initialize the configuration, and set DB values
# https://docs.getsentry.com/on-premise/server/installation/#initializing-the-configuration
cat > $SENTRY_CONF/config.yml <<EOF
system.secret-key: $($SCRIPT_DIR/generate_secret_key)
EOF

cat > $SENTRY_CONF/sentry.conf.extension.py <<EOF
DATABASES = {
    'default': {
        'ENGINE': os.environ.get('DB_ENGINE', 'sentry.db.postgres'),
        'NAME': os.environ.get('DB_NAME', 'sentry'),
        'USER': os.environ.get('DB_USER', 'postgres'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'postgres'),
        'HOST': os.environ.get('DB_HOST', 'localhost'),
        'PORT': os.environ.get('DB_PORT', '5432'),
    }
}
EOF

# Configure Redis
# https://docs.getsentry.com/on-premise/server/installation/#configure-redis
cat >> $SENTRY_CONF/config.yml <<EOF
redis.clusters:
  default:
    hosts:
      0:
        host: ${REDIS_HOST:-127.0.0.1}
        port: ${REDIS_PORT:-6379}
        password: $REDIS_PASSWORD
EOF

# Configure outbound mail
# https://docs.getsentry.com/on-premise/server/installation/#configure-outbound-mail
cat >> $SENTRY_CONF/config.yml <<EOF
mail.from: '${EMAIL_FROM:-sentry@localhost}'
mail.host: '${EMAIL_HOST:-localhost}'
mail.port: ${EMAIL_PORT:-25}
mail.username: '$EMAIL_HOST_USER'
mail.password: '$EMAIL_HOST_PASSWORD'
mail.use-tls: ${EMAIL_USE_TLS:-false}
EOF

# Static files
cat >> $SENTRY_CONF/sentry.conf.extension.py <<EOF
STATIC_ROOT = '$SENTRY_CONF/static'
EOF

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
sudo cp $SCRIPT_DIR/nginx.conf /etc/nginx/sites-available/sentry
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/sentry /etc/nginx/sites-enabled/sentry

# Re/start the Sentry server
sudo service sentry restart
sudo service nginx reload
