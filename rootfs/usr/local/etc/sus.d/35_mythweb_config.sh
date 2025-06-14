#!/bin/sh

echo "Setting up mytweb config..."

if [ -n ${MYTH_DATABASE_HOST} ]; then
    sed -i "s/\(setenv[[:space:]]\+db_server[[:space:]]\+\)\"[^\"]*\"/\1\"$MYTH_DATABASE_HOST\"/" /etc/mythtv/mythweb-mysql.conf
fi

if [ -n ${MYTH_DATABASE_NAME} ]; then
    sed -i "s/\(setenv[[:space:]]\+db_name[[:space:]]\+\)\"[^\"]*\"/\1\"$MYTH_DATABASE_NAME\"/" /etc/mythtv/mythweb-mysql.conf

fi


if [ -n ${MYTH_DATABASE_PASSWORD} ]; then
    sed -i "s/\(setenv[[:space:]]\+db_password[[:space:]]\+\)\"[^\"]*\"/\1\"$MYTH_DATABASE_PASSWORD\"/" /etc/mythtv/mythweb-mysql.conf
fi

if [ -n ${MYTH_DATABASE_USER} ]; then
    sed -i "s/\(setenv[[:space:]]\+db_login[[:space:]]\+\)\"[^\"]*\"/\1\"$MYTH_DATABASE_USER\"/" /etc/mythtv/mythweb-mysql.conf
fi

if [ -n ${MYTH_WEB_PORT} ]; then
    sed -i "s/^\(Listen[[:space:]]\+\)[0-9]\+/\1$MYTH_WEB_PORT/" /etc/apache2/ports.conf
    sed -i "s/\(<VirtualHost \*:\)[0-9]\+/\1$MYTH_WEB_PORT/" /etc/apache2/sites-enabled/000-default.conf
fi
