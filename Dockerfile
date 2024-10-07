# main image
FROM php:8.3-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libfreetype6-dev \
    libicu-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    unzip \   # Thêm đúng cách vào đây để cài đặt unzip
    zlib1g-dev \
    curl

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

RUN docker-php-ext-configure intl \
    && docker-php-ext-install bcmath calendar exif gmp intl mysqli pdo pdo_mysql mbstring xml curl zip

# installing composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# installing node js
COPY --from=node:latest /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:latest /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# installing global node dependencies
RUN npm install -g npx
RUN npm install -g laravel-echo-server

# arguments
ARG container_project_path
ARG uid
ARG user

# setting work directory
WORKDIR $container_project_path

# adding user
RUN id -u $user || useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# setting apache
COPY ./.configs/apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# setting up project from `src` folder
RUN chmod -R 775 $container_project_path
RUN chown -R $user:www-data $container_project_path

# changing user
USER $user

# Copy entrypoint script vào container
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Đảm bảo file script có quyền thực thi
RUN chmod +x /usr/local/bin/entrypoint.sh

# Thiết lập entrypoint cho container
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Đảm bảo Apache được khởi động sau khi chạy entrypoint
CMD ["apache2-foreground"]
