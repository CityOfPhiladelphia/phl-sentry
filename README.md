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

Debugging
---------

    sudo nginx -t
    sudo netstat -tulpn
