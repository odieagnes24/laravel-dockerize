FROM php:8.0-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Add docker php ext repo
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions opcache mbstring pdo_mysql zip exif pcntl gd sockets 

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git \
    curl \
    lua-zlib-dev \
    libmemcached-dev \
    nginx

# RUN apt-get install -y nodejs npm

# Install supervisor
RUN apt-get install -y supervisor

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www-data . /var/www

RUN cp docker/supervisor.conf /etc/supervisord.conf

# supervisor Log Files
RUN touch /var/log/supervisord.log && chmod 777 /var/log/supervisord.log
RUN touch /var/run/supervisord.pid && chmod 777 /var/run/supervisord.pid


COPY ./run.sh /run.sh
RUN chmod +x /run.sh

# Change current user to www
USER www

# Deployment steps
RUN composer install
# RUN npm install
# RUN npm rebuild
# RUN npm run production

# Expose port 9000 and start php-fpm server
EXPOSE 9000

ENTRYPOINT ["/run.sh"]





