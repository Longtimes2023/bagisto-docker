#!/bin/bash
set -e

# Tạo thư mục nếu chưa có
mkdir -p /var/www/html/bagisto/storage/logs
mkdir -p /var/www/html/bagisto/bootstrap/cache

# Thiết lập quyền truy cập
chmod -R 775 /var/www/html/bagisto/storage
chmod -R 775 /var/www/html/bagisto/bootstrap/cache

# Đảm bảo quyền sở hữu cho người dùng www-data
chown -R www-data:www-data /var/www/html/bagisto/storage
chown -R www-data:www-data /var/www/html/bagisto/bootstrap/cache

# Chạy lệnh mặc định của container (apache)
exec "$@"
