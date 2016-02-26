# Starting the web service
# https://docs.getsentry.com/on-premise/server/installation/#starting-the-web-service

web: sentry start --bind unix:/tmp/sentry.sock



# Starting the background workers
# https://docs.getsentry.com/on-premise/server/installation/#starting-background-workers

worker: sentry celery worker



# Starting the cron process
# https://docs.getsentry.com/on-premise/server/installation/#starting-the-cron-process

scheduler: sentry celery beat