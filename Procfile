##
# Starting the web service
# https://docs.getsentry.com/on-premise/server/installation/#starting-the-web-service

web: sentry start --bind $IP:$PORT


##
# Starting the background workers
# https://docs.getsentry.com/on-premise/server/installation/#starting-background-workers

worker: sentry celery worker


##
# Starting the scheduled process
# https://docs.getsentry.com/on-premise/server/installation/#starting-the-cron-process

scheduler: sentry celery beat