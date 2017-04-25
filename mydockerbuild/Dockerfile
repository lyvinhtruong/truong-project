FROM evadocker/staging-centos:1.1
MAINTAINER "Truong Ly <truonglv.eva@gmail.com>"
LABEL Vendor="CentOS"

RUN mkdir -p /root/.ssh/

ADD id_rsa /root/.ssh/
ADD do-github.sh /root/
ADD setup-wordpress.sh /root/
ADD fix-wordpress-permissions.sh /root/

RUN chmod 700 /root/.ssh/id_rsa && \
    echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info --allow-root && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN yum install -y wget && \
    yum install -y tar && \
    yum groupinstall -y "Development Tools" && \
    yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-devel perl-CPAN gcc perl-ExtUtils && \
    cd /usr/src && \
    wget https://github.com/git/git/archive/v2.12.2.tar.gz -O git.tar.gz && \
    tar xzf git.tar.gz && \
    cd git-2.12.2 && \
    make configure && ./configure --prefix=/usr/local && \
    make install && \
    git --version && \
    git config --global user.name "Jenkins" && \
    git config --global user.email "jenkinsbc2016@gmail.com" && \
    git config --list

EXPOSE 80

