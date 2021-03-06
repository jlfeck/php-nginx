FROM petronetto/ubuntu

MAINTAINER Juliano Petornetto <juliano@petronetto.com.br>

# Configure Ubuntu Language
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install packages
RUN add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y curl zip unzip git software-properties-common ca-certificates \
        php7.0-fpm php7.0-cli php7.0-mcrypt php7.0-mysql php7.0-pgsql \
        php-redis php7.0-mbstring php7.0-xml php7.0-zip nginx supervisor \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php \
    && apt-get remove -y --purge software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/default /etc/nginx/sites-enabled/default

# Configure PHP-FPM
COPY config/php/php.ini /etc/php/7.0/fpm/php.ini
COPY config/php/www.conf /etc/php/7.0/fpm/pool.d/www.conf


# Configure Supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/src
WORKDIR /var/www/src
COPY src/ /var/www/src/

# Fix permissions
RUN usermod -a -G www-data www-data \
    && chown -Rf www-data:www-data /var/lib/nginx \
    && chown -Rf www-data:www-data /var/www/src

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
