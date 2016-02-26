#!/usr/bin/env bash

set -e
set -x

sudo apt-get update

# PostgreSQL
sudo apt-get install -y postgresql

sudo -u ${DB_USER:-postgres} \
    createdb -E utf-8 ${DB_NAME:-sentry}
