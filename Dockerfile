FROM php:8.3.4-fpm-alpine3.19

# Ensure UTF-8
RUN apk add --update --no-cache tzdata
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TZ=${TZ:-UTC}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Nginx and other necessary packages
RUN apk add --update --no-cache nginx vim curl wget

# Create a php.ini file with the desired configuration
RUN mkdir -p /etc/php/fpm
COPY php.ini /etc/php/fpm/php.ini

# Configure PHP-FPM
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/fpm/php.ini

# Create necessary directories
RUN mkdir -p /var/www/html/public /run/nginx

# Clean up
RUN rm -rf /var/cache/apk/*

# Copy service scripts
COPY ./nginx/nginx.sh /etc/service/nginx/run
COPY ./php/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/nginx/run /etc/service/phpfpm/run

# Expose the ports
EXPOSE 9000

# Start PHP-FPM (Nginx will be started in a separate container)
CMD ["/etc/service/phpfpm/run"]
