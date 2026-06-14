#!/bin/sh

echo "Setting up mytweb config..."

if [ -n "${MYTH_DATABASE_HOST}" ]; then
    db_server_host="$MYTH_DATABASE_HOST"
    if [ -n "${MYTH_DATABASE_PORT}" ] && [ "${MYTH_DATABASE_PORT}" != "3306" ]; then
        db_server_host="$db_server_host:$MYTH_DATABASE_PORT"
    fi
    sed -i "s/\(setenv[[:space:]]\+db_server[[:space:]]\+\)\"[^\"]*\"/\1\"$db_server_host\"/" /etc/mythtv/mythweb-mysql.conf
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

if [ -n "$MYTH_WEB_PORT" ]; then
    PORTS_CONF="/etc/apache2/ports.conf"
    VHOST_CONF="/etc/apache2/sites-enabled/000-default.conf"

    # Update the Listen directive (e.g. “Listen 80”) if the file exists
    if [ -f "$PORTS_CONF" ]; then
        # -E enables extended regex: parentheses are capturing groups without backslashes
        # The replacement uses \1 (the captured “Listen … ” part) followed by the new port
        sed -i -E "s/^(Listen[[:space:]]+)[0-9]+/\\1${MYTH_WEB_PORT}/" "$PORTS_CONF"
    else
        echo "Warning: $PORTS_CONF not found – skipping Listen port update." >&2
    fi

    # Update the <VirtualHost *:port> line if the file exists
    if [ -f "$VHOST_CONF" ]; then
        sed -i -E "s/^<VirtualHost \*:[0-9]+>/<VirtualHost *:${MYTH_WEB_PORT}>/" "$VHOST_CONF"
    else
        echo "Warning: $VHOST_CONF not found – skipping VirtualHost port update." >&2
    fi
fi
