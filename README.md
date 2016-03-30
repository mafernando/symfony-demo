Symfony Demo Application
========================

Usage
-----

Generate `Dockerfile` and `docker-compose.yml` and add them to the directory containing the app code. 

Run `docker-compose up` to prepare the environment.

Use `docker exec -it symfonydemo_app_1 /bin/bash` to attach a shell to the app container.

Then execute the following to prepare the MySQL database. 

```bash
rm -rf app/cache/
composer_install
chown -R www-data:www-data /app 
php app/console doctrine:schema:create
php app/console doctrine:schema:update --force
php app/console doctrine:database:create
php app/console doctrine:fixtures:load
```

