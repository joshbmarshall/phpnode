# phpnode

This docker image contains php-fpm 7.3 on Alpine Linux with the latest stable node, currently v8.12.0

This is meant for development, so has extra packages like rsync, git and xdebug installed.

To build:
	docker build -t joshbmarshall/phpnode7 .
