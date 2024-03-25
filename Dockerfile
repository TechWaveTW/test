FROM php:7.4-apache-bullseye

RUN apt-get update && \
  apt-get install -y \
  zlib1g-dev \
  libpng-dev \
  libonig-dev \
  libzip-dev \
  libpq-dev


RUN docker-php-ext-configure gd
RUN docker-php-ext-install gd pdo pdo_mysql mysqli mbstring zip gd pdo_pgsql pgsql

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache configs
RUN a2enmod rewrite
COPY ./apache.conf /etc/apache2/sites-available/000-default.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER root

WORKDIR /var/www/html

COPY . .

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R ug+w /var/www/html

RUN composer install --optimize-autoloader --no-cache
