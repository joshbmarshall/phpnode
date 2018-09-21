# phpnode

This docker image contains php-fpm 5.6 on Alpine Linux with the latest stable node, currently v8.12.0

This is meant for development, so has extra packages like rsync, git and xdebug installed.

To build:
	docker build --cpu-period 50000 --cpu-quota=25000 -t joshbmarshall/phpnode .
