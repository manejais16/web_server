#!/bin/bash
#Desc: The script adds a db user + creates wordpress db + changes the root password to the password stored in secrets
#TODO: change the bind-address to the hostname of the wp_hostname
#!!!This script should be run as root!!!

db_root_password=$(cat /mariadb/secrets/db_root_password.txt)
db_password=$(cat /mariadb/secrets/db_password.txt)

#TODO: change the hostname to more precise definition
wp_hostname='%'
MYSQL_USER='mysql'

#TODO: remove when used for prod
echo $db_root_password
echo $db_password

export MARIADB_HOME='/mariadb'
echo "Start of init script"

if [ ! -f /mariadb/my.cnf ]
then
echo $'[mariadbd]\n bind-address = 0.0.0.0\ndatadir=/mariadb/database\nlog-basename=mariadb\nsocket=/mariadb/database/mysqld.sock\npid-file=/mariadb/database/mysqld.pid'> ${MARIADB_HOME}/my.cnf
fi

if [ ! -d /mariadb/database ]
then
echo "Creating new database"
mkdir /mariadb/database
touch mysqld.pid
chown -R mysql:mysql /mariadb/database
mysql_install_db --datadir=/mariadb/database --user=mysql
echo "The mysql_has_been installed in default directory"
mariadbd --user=root &
echo "Startig mariadb for configuration"
while ! mysqladmin ping --socket=/mariadb/database/mysqld.sock --silent
do
  sleep 1
done
mysql -uroot --socket=/mariadb/database/mysqld.sock << EOF
CREATE USER '${MYSQL_USER}'@'${wp_hostname}' IDENTIFIED BY '${db_password}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'${wp_hostname}';
FLUSH PRIVILEGES;
EOF
echo "The return value was after changing passwords " $?
passwd root << EOF
${db_root_password}
${db_root_password}
EOF
mysqladmin --socket=/mariadb/database/mysqld.sock --user=root -p${db_root_password} shutdown
echo "This is after stop"
/etc/init.d/mysql status
while [ $? -eq 0 ]
do
  sleep 1
done
echo "End of initalization"
fi

echo "running the daemon!!!!!!!"
exec mariadbd  --socket=/mariadb/database/mysqld.sock --user=mysql
