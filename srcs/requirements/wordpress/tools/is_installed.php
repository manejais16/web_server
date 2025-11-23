<?php
	#Desc: Checks if wordpress is installed
	#Return: 0 if not installed 1 if installed
	define( "WP_INSTALLING" , true);
	include_once ( "/wordpress/wp-config.php");
	include_once ( "/wordpress/wp-includes/functions.php");
	if (!is_blog_installed())
	{ exit(0);}
	else
	{ exit(1);}
?>
