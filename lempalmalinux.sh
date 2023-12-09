#!/bin/bash
yum update -y
yum install epel-release -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
yum install -y mariadb mariadb-server
systemctl start mariadb
yum -y install yum-utils
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset php
sudo dnf module install php:remi-8.1
dnf install -y php php-fpm php-ldap php-zip php-embedded php-cli php-mysql php-common php-gd php-xml php-mbstring php-mcrypt php-pdo php-soap php-json php-simplexml php-process php-curl php-bcmath php-snmp php-pspell php-gmp php-intl php-imap perl-LWP-Protocol-https php-pear-Net-SMTP php-enchant php-pear php-devel php-zlib php-xmlrpc php-tidy php-opcache php-cli php-pecl-zip unzip gcc
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -i 's|listen = 127.0.0.1:9000|listen = /var/run/php_fpm.sock|g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
systemctl start php-fpm
systemctl enable php-fpm
chmod 666 /var/run/php_fpm.sock
chown nginx:nginx /var/run/php_fpm.sock
systemctl restart nginx
touch /usr/share/nginx/html/index.php | echo 'Script by Tobi' >  /usr/share/nginx/html/index.php
