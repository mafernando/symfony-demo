FROM ubuntu

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install php5-sqlite libmysqlclient-dev git curl software-properties-common python-software-properties

ENV SYMFONY_ENV="prod" \
    PHP_VERSION="7.0.4"

RUN bin/bash -c "LANG=C.UTF-8 add-apt-repository ppa:ondrej/php" \
    && bin/bash -c "LANG=C.UTF-8 add-apt-repository ppa:ondrej/apache2" \
    && bin/bash -c "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install php7.0 libapache2-mod-php7.0 apache2 php7.0-mcrypt php7.0-mysql php7.0-json php7.0-curl php7.0-cli php7.0-mbstring php7.0-pdo-sqlite php7.0-dom" \
    && a2enmod rewrite
RUN mkdir -p /app
COPY . /app/
WORKDIR /app
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && echo "export SYMFONY_ENV='prod'" >> /etc/apache2/envvars
RUN rm /etc/apache2/sites-available/000-default.conf \
    && touch /etc/apache2/sites-available/000-default.conf \
    && echo '      <VirtualHost *:80>\n          DocumentRoot /app/web\n          <Directory /app/web>\n              Options -Indexes +FollowSymLinks +MultiViews\n              AllowOverride All\n              Require all granted\n          </Directory>\n          ErrorLog ${APACHE_LOG_DIR}/error.log\n          LogLevel warn\n          CustomLog ${APACHE_LOG_DIR}/access.log combined\n      </VirtualHost>' > /etc/apache2/sites-available/000-default.conf
RUN sed -i "/database_host/s/^/#/g" app/config/parameters.yml.dist \
    && sed -i "/database_port/s/^/#/g" app/config/parameters.yml.dist \
    && sed -i "/database_name/s/^/#/g" app/config/parameters.yml.dist \
    && sed -i "/database_user/s/^/#/g" app/config/parameters.yml.dist \
    && sed -i "/database_password/s/^/#/g" app/config/parameters.yml.dist
RUN echo "    database_host: db" >> app/config/parameters.yml.dist \
    && echo "    database_port: 3306" >> app/config/parameters.yml.dist \
    && echo "    database_name: app" >> app/config/parameters.yml.dist \
    && echo "    database_user: root" >> app/config/parameters.yml.dist \
    && echo "    database_password: ESEEN5nG9mH1L0FxDmtZqw" >> app/config/parameters.yml.dist
RUN composer install --prefer-source --no-interaction
RUN chown -R www-data:www-data /app

EXPOSE 80
