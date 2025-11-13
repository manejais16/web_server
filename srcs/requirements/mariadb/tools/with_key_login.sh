#Desc: The script to bring the password into the container and use it in executable
#!!!This script should be run as root!!!

#Should be changed for container dir ->
db_root_password=$(cat $HOME/data/secrets/db_root_password.txt)
#db_root_password=$(cat /secrets/db_root_password.txt)

echo $db_root_password
TEMP_INIT=$(mktemp tmp.XXXXXXXXXX)
chmod 600 $TEMP_INIT
echo $TEMP_INIT
#echo '\n'
echo "[client]" > $TEMP_INIT
echo "password=$db_root_password" >> $TEMP_INIT
mysql --defaults-extra-file="$TEMP_INIT" -h 127.0.0.1 -P 3304 -ubob <<EOF
#The script to run should be here
SELECT user FROM mysql.user;
EOF
rm $TEMP_INIT
#su user
#echo '\n'
exit
