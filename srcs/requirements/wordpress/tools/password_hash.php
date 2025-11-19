<?php
//Desc: Creates hash for the password that should be stored in wodpress DB
//Uses the same bcrypt cost as wordpress
$password = $argv[1];

require_once("../wp-includes/plugin.php");
require_once("../wp-includes/pluggable.php");

echo hash_password($password);

function hash_password($password) {
    return wp_hash_password($password);
}
?>
