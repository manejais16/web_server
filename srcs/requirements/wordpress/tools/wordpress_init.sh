#!/bin/bash
#Desc: The script initializes the wordpress admin and adds default website or uses the saved website that is in the folder
#!!!This script should be run as root!!!

#TODO: Add user other then admint that can edit the content
wordpress_admin_password=$(cat /wordpress/secrets/wordpress_password.txt)

#TODO: Add user injection to the wordpress & change the user to wordpress!!!
DB_hostname='mariadb'
DB_user='mysql'

export MARIADB_HOME='/wordpress'
echo "Start of init script"

#TODO: Change to better check if wp is installed
if [ ! -f /wordpress/index.php ]
then
fi

#Add the script to run the wordpress page
