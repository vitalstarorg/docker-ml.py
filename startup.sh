#!/bin/sh

sudo /etc/init.d/ssh restart

exec "$@"
