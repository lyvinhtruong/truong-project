#!/bin/sh

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            PORT)              PORT=${VALUE} ;;
            DIRECTORY)    DIRECTORY=${VALUE} ;;
            SSL_PORT)     SSL_PORT=${VALUE} ;;
            *)
    esac
done

if [ -z "$DIRECTORY" ]
then
    project_path="/var/www/html"
else
    project_path="/var/www/html/$DIRECTORY"
fi

project_path=$( echo "$project_path/" | sed 's,/[/]*/,/,g' )

if [ -z "$PORT" ]
then
    PORT=""
else
    PORT=":$PORT"
fi

if [ -z "$SSL_PORT" ]
then
    SSL_PORT=""
else
    SSL_PORT=":$SSL_PORT"
fi

source $( echo "$project_path/staging.conf.txt" | sed 's,/[/]*/,/,g' )

bkdir=$( echo "$project_path/$BACKUP_DIR/" | sed 's,/[/]*/,/,g' )
sql_data=$( ls $bkdir | sort -r | head -n1 )
data_file=$( echo "$bkdir$sql_data" | sed 's,/[/]*/,/,g' )


wp_path=$( echo "$project_path/$WP_CORE/" | sed 's,/[/]*/,/,g' )

echo "$project_path/$WP_CORE/"
echo "WP path: $wp_path"

if [ -z "$PROJECT_NAME"  ]; then
    host_name=$( cat /etc/hostname )
    share_folder="/shares/$host_name"
else
    share_folder="/shares/$PROJECT_NAME"
fi

if [ ! -d "$share_folder" ]; then
    mkdir $share_folder
fi

upload_dir=$( echo "$project_path/wp-content/uploads" | sed 's,/[/]*/,/,g' )
tmp_dir=$( echo "$project_path/wp-content/tmp" | sed 's,/[/]*/,/,g' )

if [ -d "$upload_dir" ]; then
    mkdir $tmp_dir
    cp -r $upload_dir/* $tmp_dir/
    rm -r $upload_dir
    ln -s $share_folder $upload_dir
    cp -r $tmp_dir/* $upload_dir
    rm -r $tmp_dir
else
    ln -s $share_folder $upload_dir
fi

echo "Setting default folders permission to uploads folder..."

chown root:apache -R $share_folder
chmod g+s $share_folder
setfacl -d -m g::rwx $share_folder
setfacl -d -m o::rx $share_folder
getfacl $share_folder

sh /root/fix-wordpress-permissions.sh $wp_path

cd $wp_path

if [ ! -z $SITE_DIR ]
then
project_path=$( echo "$project_path$SITE_DIR" | sed 's,/[/]*/,/,g' )
    echo "
NameVirtualHost *:80
<VirtualHost *:80>
    DocumentRoot "$project_path"
    ServerName server1.evolable.asia
    ServerAlias server1.evolable.asia
    <Directory "$project_path">
        Options +FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>

NameVirtualHost *:443
<VirtualHost *:443>
    DocumentRoot "$project_path"
    ServerName server1.evolable.asia
    ServerAlias server1.evolable.asia
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/ca.crt
    SSLCertificateKeyFile /etc/pki/tls/private/ca.key
    <Directory "$project_path">
        Options +FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>
" >> /etc/httpd/conf/httpd.conf

    service httpd restart
fi

echo "Process database..."
# wp db drop --yes --allow-root
wp db create --allow-root
wp db import "$data_file" --allow-root

echo "Replacing http://$DOMAIN to http://server1.evolable.asia$PORT"
wp search-replace "http://$DOMAIN" "http://server1.evolable.asia$PORT" --allow-root

echo "Replacing https://$DOMAIN to https://server1.evolable.asia$SSL_PORT"
wp search-replace "https://$DOMAIN" "https://server1.evolable.asia$SSL_PORT" --allow-root

