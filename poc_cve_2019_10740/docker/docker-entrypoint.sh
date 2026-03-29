#!/bin/bash
set -e
mkdir -p /var/roundcube/db
chown -R www-data:www-data /var/roundcube/db /var/www/html/temp /var/www/html/logs

# Database schema is created at image build time (see Dockerfile).

exec apache2-foreground
