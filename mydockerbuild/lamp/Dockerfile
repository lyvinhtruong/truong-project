FROM centos:6.8
MAINTAINER "Truong Ly <truonglv.eva@gmail.com>"
LABEL Vendor="CentOS 6.8 - LAMP"

RUN yum update -y && \
    yum install -y wget && \
    yum install -y tar && \
    yum install -y acl && \
    yum install -y httpd && \
    cd /root/ && \
    wget http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm && \
    yum localinstall -y mysql-community-release-el6-5.noarch.rpm && \
    yum install -y mysql-community-server && \
    yum install -y crontabs mysqltuner yum-cron sysstat postfix && \
    service mysqld start && \
    mysql_upgrade && \
    service mysqld stop && \
    echo :> /var/log/mysqld.log && \
    rm mysql-community-release-el6-5.noarch.rpm && \
    service mysqld start && \
    mysqladmin -u root password root && \
#    yum install mysql mysql-server -y && \
    yum install -y php php-pear && \
    yum install -y php-mysql && \
    yum install -y mod_ssl openssl

