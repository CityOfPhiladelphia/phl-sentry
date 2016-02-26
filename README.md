Installation Steps
------------------

    pip install honcho
    cp .env.template .env

Make appropriate modifications to *.env* file.

Create a database. If you're using a local PostgreSQL DB, you can just run `./initdb.sh`.

    ./install.sh

Then, each time you deploy, run:

    ./update.sh
