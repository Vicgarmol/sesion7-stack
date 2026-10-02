FROM php:8.3-apache
RUN docker-php-ext-install mysqli
COPY src/ /var/www/html/
RUN printf "expose_php=Off\n" > /usr/local/etc/php/conf.d/ocultar-php.ini
RUN printf "ServerTokens Prod\nServerSignature Off\n" > /etc/apache2/conf-enabled/ocultar-apache.conf
