#!/usr/bin/env bash

# Install Dependencies
# ~~~~~~~~~~~~~~~~~~~~
#
# More information at https://docs.getsentry.com/on-premise/server/installation/#dependencies

sudo apt-get install -y python-setuptools python-pip python-dev libxslt1-dev libxml2-dev libz-dev libffi-dev libssl-dev libpq-dev libyaml-dev

# PostgreSQL
sudo apt-get install -y postgresql

# Redis
if [ "$(redis-server -v)" = "" ]
then
	sudo add-apt-repository ppa:chris-lea/redis-server
	sudo apt-get update
	sudo apt-get install -y redis
fi

# Node.js
if [ "$(node -v)" = "" ]
then
	curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
	sudo apt-get install -y nodejs
	sudo apt-get install -y build-essential
fi

sudo pip install -r requirements.txt



# Initialize Sentry configuration
# https://docs.getsentry.com/on-premise/server/installation/#initializing-the-configuration

export SENTRY_CONF=/srv/sentry
echo "export SENTRY_CONF=$SENTRY_CONF"

sentry init /srv/sentry
cat >> /srv/sentry/sentry.conf.py <<EOF
DATABASES = {
    'default': {
        'ENGINE': 'sentry.db.postgres',
        'NAME': 'sentry',
        'USER': 'postgres',
        'PASSWORD': '',
        'HOST': '',
        'PORT': '',
    }
}
EOF



# Configure Redis
# https://docs.getsentry.com/on-premise/server/installation/#configure-redis

cat >> /srv/sentry/sentry.conf.py <<EOF
SENTRY_REDIS_OPTIONS = {
    'hosts': {
        0: {
            'host': '127.0.0.1',
            'port': 6379,
            'timeout': 3,
            #'password': 'redis auth password'
        }
    }
}
EOF



# Configure outbound mail
# https://docs.getsentry.com/on-premise/server/installation/#configure-outbound-mail

cat >> /srv/sentry/sentry.conf.py <<EOF
EMAIL_HOST = 'localhost'
EMAIL_HOST_PASSWORD = ''
EMAIL_HOST_USER = ''
EMAIL_PORT = 25
EMAIL_USE_TLS = False
EOF



# Static files

cat >> /srv/sentry/sentry.conf.py <<EOF
STATIC_ROOT = '$SENTRY_CONF/static'
EOF



# Run migrations
# https://docs.getsentry.com/on-premise/server/installation/#running-migrations

createdb -E utf-8 sentry
sentry upgrade
sentry createuser
sentry django collectstatic --noinput