#!/bin/bash

echo "======================================="
echo "  Download WordPress No Content"
echo "======================================="

# Lấy danh sách phiên bản có sẵn từ API WordPress
versions=$(curl -s https://api.wordpress.org/core/version-check/1.7/ | grep -oP '(?<="version":")[^"]+' | head -n 10)

echo "📌 10 phiên bản WordPress mới nhất có sẵn:"
echo "$versions" | tr ' ' '\n'
echo "======================================="

# Nhập phiên bản từ người dùng (nếu không nhập, dùng bản mới nhất)
while true; do
    read -p "Nhập phiên bản WordPress muốn tải (Enter để Down bản mới nhất - Đầy đủ): " version
    
    if [[ -z "$version" ]]; then
        url="https://wordpress.org/latest.zip"
        file_name="wordpress-latest.zip"
        echo "📌 Không nhập phiên bản. Mặc định tải về bản mới nhất!"
        break
    elif curl --head --silent --fail "https://downloads.wordpress.org/release/wordpress-${version}-no-content.zip" > /dev/null; then
        url="https://downloads.wordpress.org/release/wordpress-${version}-no-content.zip"
        file_name="wordpress-${version}-no-content.zip"
        break
    else
        echo "❌ Phiên bản không hợp lệ hoặc không tồn tại! Vui lòng nhập lại một phiên bản hợp lệ."
    fi
done

# Xác nhận tải xuống
echo "🔽 Đang tải về: $url ..."
wget -c "$url" -O "$file_name"

# Kiểm tra tải xuống có thành công không
if [[ $? -eq 0 ]]; then
    echo "✅ Tải về thành công: $file_name"
    
    # Giải nén và ghi đè nội dung vào thư mục hiện tại
    echo "📂 Đang giải nén..."
    unzip -o "$file_name" -d ./
    mv wordpress/* ./ && rmdir wordpress
    
    # Xóa file zip sau khi giải nén
    rm "$file_name"
    echo "✅ Giải nén hoàn tất và dữ liệu đã được cập nhật!"
else
    echo "❌ Lỗi! Không thể tải về. Vui lòng kiểm tra lại version đã nhập."
fi
