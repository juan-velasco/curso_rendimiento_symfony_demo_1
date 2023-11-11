FROM ubuntu:20.04

# Instalar PHP
RUN apt -y update && apt -y upgrade \
    && apt install lsb-release ca-certificates apt-transport-https software-properties-common -y \
    && add-apt-repository ppa:ondrej/php -y \
    && apt -y update \
    && apt install -y php8.2 php8.2-bcmath php8.2-cli php8.2-common php8.2-curl php8.2-dev php8.2-fpm php8.2-gd  \
    && apt install -y php8.2-igbinary php8.2-imagick php8.2-imap php8.2-intl php8.2-ldap php8.2-mbstring php8.2-pgsql php-sqlite3 \
    && apt install -y php8.2-opcache php8.2-readline php8.2-redis php8.2-soap php8.2-xml php8.2-xmlrpc php8.2-zip \
    && apt install -y wget zip libaio1 build-essential nginx

# Configurar FPM para que escuche en el puerto 9000
RUN mkdir /run/php/
RUN echo "listen = 9000" >> /etc/php/8.2/fpm/pool.d/www.conf

COPY --from=composer:2.2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY . .

RUN composer install

WORKDIR /app

RUN chmod +x ./docker/docker_wrapper_script.sh
COPY ./docker/nginx/prod/default.conf /etc/nginx/sites-enabled/default

# Forzamos entorno PROD para evitar posibles problemas de seguridad
ENV APP_ENV=prod

CMD ["./docker/docker_wrapper_script.sh"]
