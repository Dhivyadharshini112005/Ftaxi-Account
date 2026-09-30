#!/bin/sh
set -e
PORT="${PORT:-10000}"
# Render normally supplies PORT=10000. Keep Apache listening on that port.
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf || true
sed -i "s/<VirtualHost \*:10000>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf
# Ensure Laravel can write runtime directories.
mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true
exec apache2-foreground
