This repository contains scripts for deploying Sentry to a machine running
Ubuntu 14.04.

Initial Deployment Steps
------------------------

First, install `git`:

    sudo apt-get install git
    git clone https://github.com/CityOfPhiladelphia/phl-sentry.git
    cd phl-sentry

Then, set up your environment settings:

    pip install honcho
    cp .env.template .env
    # Make appropriate modifications to .env file.

Create a database. If you're using a local PostgreSQL DB, you can just run `honcho run bin/initdb`.

    honcho run bin/install

Then, each time you deploy, run:

    honcho run bin/update


Installing SSL Certificate
--------------------------

After you have a CRT/PEM file for your subdomain, copy that file to the server
along with the key file, and place them wherever the SSL_CERTIFICATE_KEY and
SSL_CERTIFICATE environment variables say to.

    ssh ubuntu@<machine> mkdir /srv/sentry/ssl/
    scp /path/to/ssl/keys/* ubuntu@<machine>:/srv/sentry/ssl/


Updating Sentry Version
-----------------------

You can check https://github.com/getsentry/sentry/releases for the latest
Sentry releases (though technically the official record will be at
https://pypi.python.org/pypi/sentry). When there is a new version and you want
to deploy it, open *requirements.txt* and update the entry for `sentry` to use
the desired version.

Commit the change with a message like "Upgrade sentry requirement to x.x.x",
and include any reasons if necessary.

SSH into *argus.phila.gov*, pull the latest changes:

    cd phl-sentry
    git pull

If necessary, update any environment variables in the *.env* file (you can use
`nano .env`). Finally, run the update script:

    honcho run bin/update
    

Debugging
---------

    sudo nginx -t
    sudo netstat -tulpn
