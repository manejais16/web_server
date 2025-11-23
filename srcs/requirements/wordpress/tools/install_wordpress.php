<?php
//Desc: Set-up for wordpress with defined admin from wp-config.php
define( "WP_INSTALLING" , true);

$blog_title = $argv[1];
$user_name = $argv[2];
$user_email = $argv[3];
$is_public = $argv[4];
$admin_password = $argv[5];
$language = $argv[6];


#dependencies for wp_install
require_once("../wp-config.php");
require_once("../wp-admin/includes/upgrade.php");

$result = wp_install($blog_title, $user_name, $user_email, $is_public, '', $admin_password, $language);

echo "WP installed!\n";
exit (0);
?>
