FROM composer:2.8 AS composer

FROM php:8.2-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev libicu-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring bcmath intl zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
    && a2enmod rewrite \
    && chown -R www-data:www-data storage bootstrap/cache

COPY docker/apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 10000
CMD ["/usr/local/bin/start.sh"]
