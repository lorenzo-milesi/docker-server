FROM php:7.3-apache-stretch

RUN apt-get -yqq update \
	&& apt-get install -yqq libpng-dev zlib1g-dev libzip-dev

RUN docker-php-ext-install pdo_mysql opcache mbstring zip gd \
	&& a2enmod rewrite negotiation

COPY php/php.ini /usr/local/etc/php/php.ini
COPY apache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY scripts/composer-installer.sh /usr/local/bin/composer-installer

RUN apt-get -yqq update \
	&& apt-get install -yqq --no-install-recommends zip unzip \
	&& chmod +x /usr/local/bin/composer-installer \
	&& composer-installer \
	&& mv composer.phar /usr/local/bin/composer \
	&& chmod +x /usr/local/bin/composer \
	&& composer --version

RUN composer global require hirak/prestissimo

WORKDIR /srv/app
