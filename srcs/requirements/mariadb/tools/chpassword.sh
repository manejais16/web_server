#!/bin/bash
#Desc: The script adds a db user + creates wordpress db + changes the root password to the password stored in secrets
#TODO: add root password so that no one can access the data
#TODO: The user has to change to mysql user
#TODO: export MARIADB_HOME="[dir]" 
#TODO: add at the dir my.cnf for server config
#!!!This script should be run as root!!!

#Should be changed for container dir ->
#db_root_password=$(cat $HOME/data/secrets/db_root_password.txt)
#db_root_password=$(cat /secrets/db_root_password.txt)
db_root_password='bob'

db_password='cat'
#db_password=$(cat /secrets/db_password.txt)
wp_hostname='%'

echo $db_root_password
echo $db_password

#The script to run should be here
echo mysql -h localhost -uroot <<"EOF"
CREATE USER '${MYSQL_USER}'@'${wp_hostname}' IDENTIFIED BY ${db_password};
ALTER USER 'root'@'localhost' IDENTIFIED BY ${db_root_password};
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'${wp_hostname}';
FLUSH PERMISIONS;
EOF

#Test to see the input of the command
#echo "CREATE USER '${MYSQL_USER}'@'${wp_hostname}' IDENTIFIED BY ${db_password}; ALTER USER 'root'@'localhost' IDENTIFIED BY ${db_root_password}; CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'${wp_hostname}';FLUSH PERMISIONS;"

#exec 
#exit
