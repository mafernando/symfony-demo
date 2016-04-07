FROM ubuntu

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install php5-sqlite libmysqlclient-dev php5 libapache2-mod-php5 php5-mcrypt php5-mysql php5-json php5-curl php5-cli git curl

ENV SYMFONY_ENV="prod" \
    PHP_VERSION="5.3.9"

RUN php5enmod mcrypt
RUN a2enmod rewrite
RUN mkdir -p /app
RUN echo "export SYMFONY_ENV='prod'" >> /etc/apache2/envvars
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY . /app/
WORKDIR /app
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
    && echo "    database_password: M-FpNg3sShKRaMBuYz8kHw" >> app/config/parameters.yml.dist
RUN composer install --prefer-source --no-interaction --no-dev
RUN chown -R www-data:www-data /app

EXPOSE 80
