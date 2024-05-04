#!/bin/bash
echo ------------------------------------------------
echo
echo Redis Server - Delete instance
echo
echo ------------------------------------------------

echo
read -p 'Please enter the name of sevice: ' RedisServiceName



if [ -f "/etc/redis/redis-$RedisServiceName.conf" ]; then

	echo 
	echo Disable instance $RedisServiceName now.
	systemctl disable redis-server@$RedisServiceName

	echo Stop the instance $RedisServiceName now.
	systemctl stop redis-server@$RedisServiceName

	echo
	echo Remove log file of the instance $RedisServiceName.
	rm /var/log/redis/redis-server-$RedisServiceName* -rf

	echo Remove configuration file of the instance $RedisServiceName.
	rm /etc/redis/redis-$RedisServiceName.conf      
	
	echo Remove data file of the instance $RedisServiceName.
	rm /var/lib/redis/$RedisServiceName.rdb  
        
else
	echo No Redis instance with the name $RedisServiceName are founded.
fi

echo
echo The script has reached the end.
