#!/usr/bin/env sh

. venv/bin/activate
./manage.py migrate
DJANGO_SUPERUSER_PASSWORD="admin" ./manage.py createsuperuser --noinput --username admin --email admin@localhost
./manage.py collectstatic --noinput
nginx -g 'daemon off;' &
uwsgi --ini /etc/uwsgi/bounca.ini
