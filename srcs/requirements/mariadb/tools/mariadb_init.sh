#!/bin/bash
#Desc: The script adds a db user + creates wordpress db + changes the root password to the password stored in secrets
#TODO: add at the dir my.cnf for server config
#TODO: change the bind-address to the hostname of the wp_hostname
#TODO: The script should not run if the root is already initialized
#TODO: The database should be persistent change data socke dir also log
#!!!This script should be run as root!!!

db_root_password=$(cat /mariadb/secrets/db_root_password.txt)
db_password=$(cat /mariadb/secrets/db_password.txt)

#db_password=$(cat /secrets/db_password.txt)
#TODO: change the hostname to more precise definition
wp_hostname='%'
MYSQL_USER='mysql'

#TODO: remove when used for prod
echo $db_root_password
echo $db_password

#/etc/init.d/mariadb restart
/etc/init.d/mariadb start 
#The script to run should be here
mysql -u root <<EOF
CREATE USER '${MYSQL_USER}'@'${wp_hostname}' IDENTIFIED BY '${db_password}';
#ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'${wp_hostname}';
FLUSH PRIVILEGES;
EOF

chpasswd << EOF
mysql:${db_password}
EOF

passwd root << EOF
${db_root_password}
${db_root_password}
EOF

/etc/init.d/mariadb stop
export MARIADB_HOME=${HOME}

#TODO: Change the hosts
echo $'[mariadbd]\n bind-address = 0.0.0.0' > ${MARIADB_HOME}/my.cnf

exec mariadbd --user=mysql

