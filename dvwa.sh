#!/bin/bash
systemctl stop firewalld
systemctl disable firewalld
sudo dnf update -y
sudo dnf install epel-release -y
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo dnf install nginx -y
sudo systemctl enable --now nginx
sudo dnf install mariadb-server -y
sudo systemctl enable --now mariadb
sudo dnf install php php-fpm php-mysqlnd php-gd php-mbstring php-xml php-common php-curl php-json php-zip -y
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
sudo systemctl enable --now php-fpm
sudo dnf install -y git
cd /var/www/
sudo git clone https://github.com/digininja/DVWA.git
sudo mv DVWA dvwa
sudo chown -R nginx:nginx /var/www/dvwa
sudo chmod -R 755 /var/www/dvwa
cp /var/www/dvwa/config/config.inc.php.dist /var/www/dvwa/config/config.inc.php
sed -i 's/127.0.0.1/localhost/g' /var/www/dvwa/config/config.inc.php
sudo bash -c 'cat > /etc/nginx/conf.d/dvwa.conf <<EOF
server {
    listen 80;
    server_name dvwa.quyenlt.com;
    root /var/www/dvwa;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF'
sed -i 's/display_errors = Off/display_errors = On/g' /etc/php.ini
sed -i 's/display_startup_errors = Off/display_startup_errors = On/g' /etc/php.ini
sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php.ini
sudo systemctl restart php-fpm
sudo systemctl restart nginx
sudo mysql -e "CREATE DATABASE dvwa; CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd'; GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost'; FLUSH PRIVILEGES;"
cd /var/www/dvwa
sudo dnf install composer -y
sudo COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction
sudo chown -R nginx:nginx /var/lib/php/session
sudo chmod -R 770 /var/lib/php/session
echo "==========================================="
echo " Quá trình cài DVWA đã hoàn tất!"
echo " Truy cập vào đường dẫn: http://MY_IP"
echo " Login với user: admin và password: password"
echo " Xuống cuối trang chọn 'Create/Reset Database'"
echo " Sau đó đăng nhập lại một lần nữa là thành công!"
echo " Ủng hộ tôi tại https://quyenlt.com/donate-tobi/"
echo " Chúc các bạn thành công!"
echo "==========================================="
