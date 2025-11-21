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
echo $'[mariadbd]\nbind-address = 0.0.0.0
datadir=/mariadb/database\nlog-basename=mariadb
socket=/mariadb/database/mysqld.sock
pid-file=/mariadb/database/mysqld.pid'> ${MARIADB_HOME}/my.cnf
echo $'[mysql]\nsocket=/mariadb/database/mysqld.sock
[mysqladmin]\nsocket=/mariadb/database/mysqld.sock' > ~/.my.cnf
fi

if [ ! -d /mariadb/database ]
then
echo "Creating new database"
mkdir /mariadb/database
#touch mysqld.pid
chown -R mysql:mysql /mariadb/database
mysql_install_db --datadir=/mariadb/database --user=mysql
echo "The mysql_has_been installed in default directory"
mariadbd --user=root &
echo "Startig mariadb for configuration"
while ! mysqladmin ping --silent
do
  sleep 1
done
mysql -uroot << EOF
CREATE USER '${MYSQL_USER}'@'${wp_hostname}' IDENTIFIED BY '${db_password}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
CREATE DATABASE wordpress;
DROP DATABASE test;
DROP USER ''@'localhost';
DROP USER ''@'mariadb';
GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'${wp_hostname}';
FLUSH PRIVILEGES;
EOF
echo "The return value was after changing passwords " $?
passwd root << EOF
${db_root_password}
${db_root_password}
EOF
mysqladmin --user=root -p${db_root_password} shutdown
echo "This is after stop"
while mysqladmin ping --silent
do
  sleep 1
done
echo "End of initalization"
fi

echo "running the daemon!!!!!!!"
exec mariadbd --user=mysql
