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

