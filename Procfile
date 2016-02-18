web: sentry start --bind $IP:$PORT
# The string $IP:$PORT could instead refer to a unix socket if you  set your
# IP to "unix" and your PORT to some file name.

worker: sentry celery worker

scheduler: sentry celery beat