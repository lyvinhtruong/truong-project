#!/bin/sh

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            PORT)              PORT=${VALUE} ;;
            DIRECTORY)    DIRECTORY=${VALUE} ;;
            *)
    esac
done

if [ -z "$DIRECTORY" ]
then
    project_path="/var/www/html"
else
    project_path="/var/www/html/$DIRECTORY"
fi

if [ -z "$PORT" ]
then
    PORT=""
else
    PORT=":$PORT"
fi

source "$project_path/staging.conf.txt"

sql_data=$( ls $project_path/$BACKUP_DIR/ | sort -r | head -n1 )

data_file=$( echo "$project_path/$BACKUP_DIR/$sql_data" | sed 's,//,/,g' )
wp_path=$( echo "$project_path/$WP_CORE/" | sed 's,//,/,g' )

sh /root/fix-wordpress-permissions.sh $wp_path

cd $wp_path

if [ ! -z $SITE_DIR ]
then
    echo "
NameVirtualHost *:80
<VirtualHost *:80>
    DocumentRoot "$project_path$SITE_DIR"
    ServerName staging.evolable.asia
    ServerAlias staging.evolable.asia
    <Directory "$project_path$SITE_DIR">
        Options +FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>
" >> /etc/httpd/conf/httpd.conf

    service httpd restart
fi

# wp db drop --yes --allow-root
wp db create --allow-root
wp db import "$data_file" --allow-root
wp search-replace "$DOMAIN" "staging.evolable.asia$PORT" --allow-root

