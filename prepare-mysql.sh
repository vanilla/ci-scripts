# #!/bin/bash
#
# Script for preparing MySQL instance

# Installation
sudo apt-get update && sudo apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev
sudo docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
sudo docker-php-ext-install pdo pdo_mysql gd
sudo apt-get install mysql-client

# Create the SQL "circleci" user. Once we remove travis this should no longer be necessary.
mysql -h 127.0.0.1 -u root -e \
    "CREATE USER 'circleci'@'127.0.0.1'; GRANT ALL PRIVILEGES ON vanilla_test.* TO 'circleci'@'127.0.0.1' IDENTIFIED BY '';"

# Wait for the connection to be ready.
for i in `seq 1 30`;
do
nc -z 127.0.0.1 3306 && echo Success && exit 0
echo -n .
sleep 1
done
echo Failed waiting for MySQL && exit 1