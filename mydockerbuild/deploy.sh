#!/bin/bash

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            PORT)              PORT=${VALUE} ;;
            REPOSITORY)    REPOSITORY=${VALUE} ;;     
            BRANCH)    BRANCH=${VALUE} ;;
            DIRECTORY)   DIRECTORY=${VALUE} ;;
            *)   
    esac    

done

if [ -z "$PORT" ]
then
    echo "Please enter port number (9091~9096) :"
    read input_port
else
    input_port=$PORT    
fi

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

    if [ -z "$REPOSITORY"  ]
    then
        echo "Please enter GitHub repository URL :"
        read repo
    else
        repo=$REPOSITORY
    fi

    if [ -z "$BRANCH" ]
    then
        echo "Please enter branch name to checkout :"
        read branch
    else
        branch=$BRANCH
    fi

    if [ -n "$repo" ]
    then
        docker exec -it $container sh /root/do-github.sh $repo $branch
    fi

    docker exec -it $container cd /var/www/html/ && \
    wget https://github.com/interconnectit/Search-Replace-DB/archive/master.zip -O Search-Replace-DB.zip  && \
    unzip Search-Replace-DB.zip

    echo "Setting up Wordpress site :"

    if [ -z "$DIRECTORY" ]
    then
        echo "Please type folder name of project as listed below:"
        read project_folder
        DIRECTORY=$project_folder
    fi

    docker exec -it $container sh /root/setup-wordpress.sh DIRECTORY=$DIRECTORY PORT=$input_port

    echo "Success! You have just created a new machine with detail information as below:"
    echo "    Container ID : $container"
    echo "    IP Address   : $ip_address"
    echo "    Public URL   : http://staging.evolable.asia:$input_port/"
fi

