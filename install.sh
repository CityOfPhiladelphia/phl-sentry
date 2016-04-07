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



# Create the folder for the Sentry configuration
export SENTRY_CONF=/srv/sentry
sudo mkdir --parents $SENTRY_CONF
sudo chown $(whoami):$(whoami) $SENTRY_CONF
echo "export SENTRY_CONF=$SENTRY_CONF" >> ~/.bashrc



# Initialize Sentry Configuration
# https://docs.getsentry.com/on-premise/server/installation/#initializing-the-configuration

sentry init $SENTRY_CONF
touch $SENTRY_CONF/sentry.conf.extension.py
cat >> $SENTRY_CONF/sentry.conf.py <<EOF
with open("$SENTRY_CONF/sentry.conf.extension.py") as f:
    code = compile(f.read(), "sentry.conf.extension.py", 'exec')
    exec(code, globals(), locals())
EOF


# Run migrations
# https://docs.getsentry.com/on-premise/server/installation/#running-migrations

honcho run sentry upgrade --noinput
honcho run sentry createuser \
    --email "$SENTRY_ADMIN_EMAIL" \
    --superuser \
    --no-input \
    --no-password  # User will have to reset their password
