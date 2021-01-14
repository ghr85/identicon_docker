#! /bin/bash
set -e

if [ "$ENV" = 'DEV' ]; then
    echo "Running dev server"
    exec python "identidock.py"
elif [ "$ENV" = 'UNIT']; then
    echo "Running unit tests"
    exec python "tests.py"
else
    echo "$ENV"
    echo "Running Production Server"
    exec uwsgi --http 0.0.0.0:9090 --wsgi-file /app/identidock.py --callable app --stats 0.0.0.0:9191
fi

