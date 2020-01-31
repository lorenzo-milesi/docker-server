#
# I : Image de base.
# ----------------------------------------------------------------------------------------------------------------------
# php7.3 sur serveur apache
FROM php:7.3-apache-stretch
#
# II : Dépendances, extensions php et modules apache.
# ----------------------------------------------------------------------------------------------------------------------
RUN apt-get -yqq update \
	&& apt-get install -yqq libpng-dev zlib1g-dev libzip-dev wget
RUN docker-php-ext-install pdo_mysql opcache mbstring zip gd exif mbstring intl \
	&& a2enmod rewrite negotiation
#
# III : Fichiers de configuration.
# ----------------------------------------------------------------------------------------------------------------------
# php.ini, vhost apache et scripts d'installation
COPY php/php.ini /usr/local/etc/php/php.ini
COPY apache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY scripts/composer-installer.sh /usr/local/bin/composer-installer
#
# IV : Installations de composants.
# ----------------------------------------------------------------------------------------------------------------------
# 1 : composer.
RUN apt-get -yqq update \
	&& apt-get install -yqq --no-install-recommends zip unzip \
	&& chmod +x /usr/local/bin/composer-installer \
	&& composer-installer \
	&& mv composer.phar /usr/local/bin/composer \
	&& chmod +x /usr/local/bin/composer \
	&& composer --version
#
# 1.1 : paquets composer globaux.
# prestissimo : extrêmement utile pour rendre composer rapide.
RUN composer global require hirak/prestissimo
#
# 2 : nvm, node, npm et yarn
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.13.1
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
RUN node -v
RUN npm -v
RUN npm i -g yarn
RUN yarn -v
#
# 3 : Symfony / Laravel et cie.
#
RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN composer global require laravel/installer
#
# 4 : Add bins to PATH
#
RUN echo 'PATH="$HOME/.composer/vendor/bin:$HOME/.symfony/bin:$PATH"' >> ~/.bashrc

WORKDIR /srv/app
