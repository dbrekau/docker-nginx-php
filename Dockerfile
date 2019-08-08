FROM alpine:edge

RUN apk update

# Create user
RUN adduser -D -g 'www' www

# Install nginx
    RUN apk add nginx
    # Create missing directory
    RUN mkdir /run/nginx
    # Create directories and set permissions
    RUN mkdir /www
    RUN chown -R www.www /www
    RUN chown -R www.www /var/lib/nginx
    # Copy config
    COPY config/nginx.conf /etc/nginx/nginx.conf

# Install PHP
    # Defaults from Alpine Wiki
    RUN apk add php7-fpm php7-mcrypt php7-soap php7-openssl php7-gmp php7-pdo_odbc php7-json php7-dom php7-pdo php7-zip php7-mysqli php7-sqlite3 php7-apcu php7-pdo_pgsql php7-bcmath php7-gd php7-odbc php7-pdo_mysql php7-pdo_sqlite php7-gettext php7-xmlreader php7-xmlrpc php7-bz2 php7-iconv php7-pdo_dblib php7-curl php7-ctype
    # Additional extensions
    RUN apk add php7-pgsql php7-session php7-xmlwriter php7-mbstring php7-simplexml
    # Copy config
    COPY config/php7.sh /etc/profile.d/php7.sh
    # Modify www.conf
    COPY config/www.conf.sh /www.conf.sh
    RUN /www.conf.sh
    # Modify php.ini
    COPY config/php.ini.sh /php.ini.sh
    RUN /php.ini.sh
    # Timezone
    RUN apk add tzdata
    ENV TIMEZONE="Europe/Berlin"
    RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
    RUN echo "${TIMEZONE}" > /etc/timezone
    RUN sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini

COPY copy/index.html /www/index.html
COPY copy/index.php /www/index.php

# Debug
    RUN apk add bash

# Clean
    RUN rm -rf /var/cache/apk/*

# Defaults
    EXPOSE 80
    STOPSIGNAL SIGTERM
    COPY copy/entrypoint.sh /entrypoint.sh
    ENTRYPOINT ["/entrypoint.sh"]
