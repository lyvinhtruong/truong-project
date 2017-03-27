FROM evadocker/staging-centos
MAINTAINER "Truong Ly <truonglv.eva@gmail.com>"
LABEL Vendor="CentOS"

RUN mkdir -p /root/.ssh
ADD id_rsa /root/.ssh/id_rsa
ADD do-github.sh /root/
RUN chmod 700 /root/.ssh/id_rsa && \
    echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info --allow-root && \
   chmod +x wp-cli.phar && \
   mv wp-cli.phar /usr/local/bin/wp

EXPOSE 80

