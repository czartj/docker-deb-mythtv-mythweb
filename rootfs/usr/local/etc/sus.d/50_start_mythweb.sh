#!/bin/sh

echo "Starting mythweb..."
/command/s6-svc -u /run/service/apache2
