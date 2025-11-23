#!/bin/bash
# Script để restart MongoDB replica set với slaveDelay configuration

echo "🔄 Restarting MongoDB replica set với slaveDelay 20s..."
echo ""

# Stop và remove containers cũ
echo "1. Stopping existing containers..."
docker-compose -f phanta-docker-compose.yml down

# Xóa volumes cũ để reset data (optional - comment out nếu muốn giữ data)
echo "2. Removing old volumes..."
docker volume rm nhom2_rbac_mongo-primary-data nhom2_rbac_mongo-secondary-data 2>/dev/null || true

# Start lại với config mới
echo "3. Starting containers with new configuration..."
docker-compose -f phanta-docker-compose.yml up -d

echo ""
echo "✅ Đã restart! Đợi 30 giây để replica set khởi tạo..."
sleep 30

# Kiểm tra status
echo ""
echo "4. Checking replica set status..."
docker exec mongo-primary mongo --eval "rs.status()" --quiet | grep -A 5 "secondaryDelaySecs"

echo ""
echo "✅ Hoàn thành! Replica set đã được cấu hình với slaveDelay: 20 giây"
echo ""
echo "📝 Lưu ý:"
echo "   - Secondary sẽ delay 20 giây so với Primary"
echo "   - Không cần chạy apply_delay.sh nữa"
echo "   - Có thể bắt đầu chạy notebook ngay"
