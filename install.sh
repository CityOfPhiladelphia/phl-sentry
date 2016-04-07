#!/usr/bin/env bash

set -ex
SCRIPT_DIR=$(dirname $0)

# Install Dependencies
# ~~~~~~~~~~~~~~~~~~~~
#
# More information at https://docs.getsentry.com/on-premise/server/installation/#dependencies

sudo apt-get update
sudo apt-get install -y python-setuptools python-pip python-dev libxslt1-dev libxml2-dev libz-dev libffi-dev libssl-dev libpq-dev libyaml-dev

# PostgreSQL
sudo apt-get install -y postgresql

# Redis
if [ "$(redis-server -v)" = "" ]
then
	sudo add-apt-repository -y ppa:chris-lea/redis-server
	sudo apt-get update
	sudo apt-get install -y redis-server
fi

# Node.js
if [ "$(node -v)" = "" ]
then
	curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
	sudo apt-get install -y nodejs
	sudo apt-get install -y build-essential
fi

# Install python requirements
sudo pip install --requirement requirements.txt

# # Install node requirements
# sudo npm install --global



# Create the folder for the Sentry configuration
export SENTRY_CONF=/srv/sentry
sudo mkdir --parents $SENTRY_CONF
sudo chown $(whoami):$(whoami) $SENTRY_CONF
echo "export SENTRY_CONF=$SENTRY_CONF" >> ~/.bashrc



# Initialize the configuration, and set DB values
# https://docs.getsentry.com/on-premise/server/installation/#initializing-the-configuration

sentry init $SENTRY_CONF

honcho run bash
cat > $SENTRY_CONF/config.yml <<EOF
system.secret-key: $($SCRIPT_DIR/generate_secret_key)
EOF
exit

cat >> $SENTRY_CONF/sentry.conf.py <<EOF
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

honcho run bash
cat >> $SENTRY_CONF/config.yml <<EOF
redis.clusters:
  default:
    hosts:
      0:
        host: ${REDIS_HOST:-127.0.0.1}
        port: ${REDIS_PORT:-6379}
        password: $REDIS_PASSWORD
EOF
exit



# Configure outbound mail
# https://docs.getsentry.com/on-premise/server/installation/#configure-outbound-mail

honcho run bash
cat >> $SENTRY_CONF/config.yml <<EOF
mail.from: '${EMAIL_FROM:-sentry@localhost}'
mail.host: '${EMAIL_HOST:-localhost}'
mail.port: ${EMAIL_PORT:-25}
mail.username: '$EMAIL_HOST_USER'
mail.password: '$EMAIL_HOST_PASSWORD'
mail.use-tls: ${EMAIL_USE_TLS:-false}
EOF
exit



# Static files

cat >> $SENTRY_CONF/sentry.conf.py <<EOF
STATIC_ROOT = '$SENTRY_CONF/static'
EOF



# Run migrations
# https://docs.getsentry.com/on-premise/server/installation/#running-migrations

honcho run sentry upgrade --noinput
honcho run sentry createuser \
    --email "$SENTRY_ADMIN_EMAIL" \
    --superuser \
    --no-input \
    --no-password  # User will have to reset their password
