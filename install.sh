#!/usr/bin/env bash

set -ex

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



# Initialize Sentry configuration
# https://docs.getsentry.com/on-premise/server/installation/#initializing-the-configuration

export SENTRY_CONF=/srv/sentry
echo "export SENTRY_CONF=$SENTRY_CONF" >> ~/.bashrc

sentry init $SENTRY_CONF
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

cat >> $SENTRY_CONF/sentry.conf.py <<EOF
SENTRY_REDIS_OPTIONS = {
    'hosts': {
        0: {
            'host': os.environ.get('REDIS_HOST', '127.0.0.1'),
            'port': int(os.environ.get('REDIS_PORT', 6379)),
            'timeout': int(os.environ.get('REDIS_TIMEOUT', 3)),
            'password': os.environ.get('REDIS_PASSWORD', None)
        }
    }
}
EOF



# Configure outbound mail
# https://docs.getsentry.com/on-premise/server/installation/#configure-outbound-mail

cat >> $SENTRY_CONF/sentry.conf.py <<EOF
EMAIL_HOST = os.environ.get('EMAIL_HOST', 'localhost')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 25))
EMAIL_USE_TLS = (os.environ.get('EMAIL_USE_TLS', 'False') == 'True')
EOF



# Static files

cat >> $SENTRY_CONF/sentry.conf.py <<EOF
STATIC_ROOT = '$SENTRY_CONF/static'
EOF



# Run migrations
# https://docs.getsentry.com/on-premise/server/installation/#running-migrations

sentry upgrade
sentry createuser \
    --email "$SENTRY_ADMIN_EMAIL" \
    --superuser \
    --no-input \
    --no-password  # User will have to reset their password
