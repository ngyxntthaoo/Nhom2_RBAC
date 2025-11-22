#!/bin/bash
# Script để bật delay trên mongo-secondary SAU KHI replica set đã được khởi tạo

echo "Kiểm tra delay hiện tại trên mongo-secondary..."
current_delay=$(docker exec mongo-secondary tc qdisc show dev eth0 2>/dev/null)

if echo "$current_delay" | grep -q "delay"; then
    echo "✅ Delay đã được áp dụng rồi!"
    echo "Cấu hình hiện tại:"
    echo "$current_delay"
else
    echo "Applying 3000ms network delay to mongo-secondary..."
    docker exec mongo-secondary tc qdisc add dev eth0 root netem delay 3000ms

    if [ $? -eq 0 ]; then
        echo "✅ Delay 3000ms đã được áp dụng thành công!"
        echo "Kiểm tra:"
        docker exec mongo-secondary tc qdisc show dev eth0
    else
        echo "❌ Lỗi khi áp dụng delay"
    fi
fi
