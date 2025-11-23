#!/bin/bash
#Desc: The script initializes the wordpress 
#!!!The DOMAIN and PORT env vars should be set!!!

#TODO: Add different user in db so it is more descriptive
#TODO: Add user injection to the wordpress & change the user to wordpress!!!
DB_hostname='mariadb'
#TODO: Add the env vars through docker compose for these settings!
DOMAIN='localhost'
wordpress_tool_dir='/content/tools/'
mariadb_wordpress_user_password=$(cat /wordpress/secrets/db_password.txt)
wordpress_admin_password=$(cat /wordpress/secrets/wordpress_admin_password.txt)
export WORDPRESS_HOME='/wordpress'
echo "Start of init script"

#TODO: Change the name and host of the database also add port
init_config_file() {
	echo 'Initializing config file.'
cat > /wordpress/wp-config.php << EOF
<?php
define ('WP_CONTENT_DIR', '/wordpress/wp-content');
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', '${MYSQL_WORDPRESS_USER}' );
define( 'DB_PASSWORD', '${mariadb_wordpress_user_password}');
define( 'DB_HOST', '${DB_hostname}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
\$table_prefix = 'wp_';
\$wp_home = '${WORDPRESS_INTERNAL_PROTOCOL}' . '${DOMAIN}'  . ':' . '${WORDPRESS_PORT}';
define( 'WP_HOME', \$wp_home );
define( 'WP_SITEURL', \$wp_home );
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF
	echo "Config file initialized."	
}

#TODO: Inject the title, username, e-mail, etc through the envars.
if [ ! -f "/wordpress/wp-config.php" ]
then

	init_config_file
fi

while ! mysqladmin -h ${DB_hostname} -uroot ping &> /dev/null
do
	sleep 1
	echo "hello"
done

php ${wordpress_tool_dir}is_installed.php
if [ $? == 0 ] 
then
	echo "Installing wordpress"
	php ${wordpress_tool_dir}install_wordpress.php "The blog" "${WORDPRESS_ADMIN_USER}" 'admin@admin.com' 0 "${wordpress_admin_password}" ''
	php ${wordpress_tool_dir}is_installed.php
	if [ $? == 0 ] 
	then
		echo "ERROR: Could not install wordpress. Check configuration inputs"
		exit -1
	else
		echo "Initialization successfull!"
	fi
fi
cd /wordpress

useradd -m wordpress
chmod -R 500 /wordpress
chmod -R 700 /wordpress/wp-content
chown -R wordpress /wordpress

#TODO: Think of a more elegant solution
su -c 'php -S 0.0.0.0:${WORDPRESS_PORT}' wordpress
