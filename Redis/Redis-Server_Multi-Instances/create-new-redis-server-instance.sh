#!/bin/bash
echo ------------------------------------------------
echo
echo Redis Server - Create new instance
echo
echo ------------------------------------------------

echo
read -p 'Please enter the name of sevice: ' RedisServiceName

echo
echo  Create a default password for the redis instance.
RedisInstancePassword=$(date +%s|sha256sum|base64|head -c 32 ; echo)

echo Check which port in the defined port range are unsed.
RedisInstancePort=$(comm -23 <(seq 6380 6400 | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u)  | head -n 1)
echo

echo Check if the configuration alrady exist. Please wait...
if [ -f "/etc/redis/redis-$RedisServiceName.conf" ]; then
        echo The configuration file $RedisServiceName already exists.
else
        echo Create a new configuration file for this instance.
		
cat << EOF > /etc/redis/redis-$RedisServiceName.conf

# Default values for every instance
include /etc/redis/redis.conf

# Custom values for this instance
# This will overwrite the settings of redis.conf
port $RedisInstancePort
requirepass $RedisInstancePassword

#pidfile /run/redis/redis-$RedisServiceName.pid
logfile /var/log/redis/redis-server-$RedisServiceName.log
dbfilename $RedisServiceName.rdb
dir /var/lib/redis


EOF

	echo
	echo  Set the owner of the new configuration file.
	chown redis:redis /etc/redis/redis-$RedisServiceName.conf

	echo Enable new instance now.
	systemctl enable redis-server@$RedisServiceName

	echo  Start the new instance now.
	systemctl start redis-server@$RedisServiceName

	echo
	echo Instance Informations
	echo ------------------------------------------------
	echo Instance Name: $RedisServiceName
	echo Instance Port: $RedisInstancePort
	echo Instance Pass: $RedisInstancePassword
	echo ------------------------------------------------
	echo

	echo Check status fof the new instance
	systemctl status redis-server@$RedisServiceName

fi

echo
echo The script has reached the end.
