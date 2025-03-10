#!/bin/bash

# Cập nhật hệ thống và cài đặt Apache2
echo "Đang cập nhật hệ thống..."
sudo apt update -y && sudo apt upgrade -y

echo "Cài đặt Apache2..."
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo a2enmod auth_digest
sudo systemctl restart apache2
# Chuyển đến thư mục /var/www/html
echo "Tạo file index.html và thư mục digest..."
cd /var/www/html/

# Tạo file index.html cho Basic Authentication
echo "Test Basic Authentication" | sudo tee /var/www/html/index.html > /dev/null

# Tạo thư mục digest và file index.html cho Digest Authentication
sudo mkdir -p /var/www/html/digest
echo "Test Digest Authentication" | sudo tee /var/www/html/digest/index.html > /dev/null

# Xóa nội dung file cấu hình Apache mặc định
CONFIG_FILE="/etc/apache2/sites-available/000-default.conf"
echo "Làm rỗng file cấu hình Apache: $CONFIG_FILE"
sudo truncate -s 0 $CONFIG_FILE

# Ghi nội dung mới vào file cấu hình Apache
echo "Thêm nội dung mới vào $CONFIG_FILE"
echo "" > $CONFIG_FILE
sudo tee $CONFIG_FILE > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    <Directory "/var/www/html"> #doan cau hinh basic auth
        AuthType Basic
        AuthName "Restricted Area"
        AuthUserFile "/etc/apache2/.htpasswd"
        Require valid-user
    </Directory>
    <Directory "/var/www/html/digest"> # doan cau hinh cua digest
        AuthType Digest
        AuthName "MyProtectedArea"
        AuthUserFile "/etc/apache2/.htdigest"
        Require valid-user
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Hỏi người dùng nhập tên user
echo -n "Nhập tên user cho Basic Authentication: "
read BASIC_USER

echo -n "Nhập tên user cho Digest Authentication: "
read DIGEST_USER

# Tạo tài khoản Basic Authentication
echo "Tạo tài khoản cho phần Basic Authentication..."
sudo htpasswd -c /etc/apache2/.htpasswd "$BASIC_USER"

# Tạo tài khoản Digest Authentication
echo "Tạo tài khoản cho phần Digest Authentication..."
sudo htdigest -c /etc/apache2/.htdigest "MyProtectedArea" "$DIGEST_USER"

# Restart Apache để áp dụng cấu hình mới
echo "Khởi động lại Apache..."
sudo systemctl restart apache2

# Hiển thị thông báo hoàn tất
echo "Quá trình cấu hình hoàn tất!"
echo "Bạn có thể kiểm tra với Basic Authentication tại: http://mydomain.com hoặc http://my_IP"
echo "Với Digest Authentication: http://mydomain.com/digest hoặc http://my_IP/digest"
echo "Script By Tobi ! quyenlt.com"

