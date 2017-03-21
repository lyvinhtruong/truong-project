#!/bin/bash

echo "Please enter port number (9091~9096) :"
read input_port

if [ $input_port -gt 9096 ] || [ $input_port -lt 9091 ]
then
    echo "You have entered invalid port"
else
    echo "Checking port $input_port ..."
    port_open=$( sudo netstat -tulpn | grep $input_port )
    
    if [ -z "$port_open" ]
    then
        echo "Port $input_port is available"
    else
        echo "Port $input_port is unavailable now."
        exit 1
    fi

    echo "Creating new container..."
    container=$( docker run -dti -p $input_port:80 evadocker/staging-centos /bin/bash )
    echo "$container"

    ip_address=$( docker inspect $container | grep -w "IPAddress" | awk '{ print $2 }' | head -n 1 | cut -d "," -f1 )
    ip_address=$( echo $ip_address | tr -d '"' )

    echo "Staring apache service..."
    httpd_status=$( docker exec -dti $container service httpd start )
    echo "$httpd_status"
    
    echo "Starting MySQL..."
    mysql_status=$( docker exec -dti $container service mysqld start )
    echo "$mysql_status"

    echo "Success! You have just created a new machine with detail information as below:"
    echo "    Container ID : $container"
    echo "    IP Address   : $ip_address"
    echo "    Public URL   : http://staging.evolable.asia:$input_port/"
fi

