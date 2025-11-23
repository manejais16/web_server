#!/bin/bash
#Desc: The script initializes the wordpress 
#!!!The DOMAIN and PORT env vars should be set!!!

#TODO: Add different user in db so it is more descriptive
#TODO: Add user injection to the wordpress & change the user to wordpress!!!
DB_hostname='mariadb'
DB_user='mysql'
protocol='http://'
#TODO: Add the env vars through docker compose for these settings!
export DOMAIN='localhost'
wordpress_admin_username='admin'
export PORT='9000'
mariadb_wordpress_user_password=$(cat ${HOME}/wordpress/secrets/db_password.txt)
wordpress_admin_password=$(cat ${HOME}/wordpress/secrets/wordpress_admin_password.txt)
export WORDPRESS_HOME='/wordpress'
echo "Start of init script"

#TODO: Change the name and host of the database
init_config_file() {
	echo 'Initializing config file.'
cat > ${HOME}/wordpress/wp-config.php << EOF
<?php
define ('WP_CONTENT_DIR', '${HOME}/wordpress/wp-content');
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', '${DB_user}' );
define( 'DB_PASSWORD', '${mariadb_wordpress_user_password}');
define( 'DB_HOST', '127.0.0.1' );
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
\$wp_home = '${protocol}' . getenv('DOMAIN') . ':' . getenv('PORT');
define( 'WP_HOME', \$wp_home );
define( 'WP_SITEURL', \$wp_home );
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF
	echo "Config file initialized."	
}

#TODO: Change to better check if wp is installed
#TODO: Inject the title, username, e-mail, etc through the envars.
if [ ! -f "${HOME}/wordpress/wp-config.php" ]
then

	init_config_file
fi

php ./is_installed.php
is_installed=$?;
echo $is_installed;
if [ $is_installed == 0 ] 
then
	echo "Installing wordpress"
	php ./install_wordpress.php "The blog" "${wordpress_admin_username}" 'admin@admin.com' 0 "${wordpress_admin_password}" ''
	php ./is_installed.php	
	is_installed=$?;
	echo $is_installed;
	if [ $is_installed == 0 ] 
	then
		echo "ERROR: Could not install wordpress. Check configuration inputs"
		exit -1
	else
		echo "Initialization successfull!"
	fi
fi
cd ${HOME}/wordpress

chmod -R 600 ${HOME}/wordpress/secrets
chown -R root ${HOME}/wordpress/secrets

#TODO: Change the user to not be root
php -S ${DOMAIN}:${PORT}
