#!/bin/bash
set -e

# Tìm cypher-shell tự động
NEO4J_PATH=$(find ~/Library/Application\ Support/neo4j-desktop -name "cypher-shell" -type f 2>/dev/null | head -1)

if [ -z "$NEO4J_PATH" ]; then
  echo "❌ Không tìm thấy cypher-shell"
  echo "Hãy cài đặt Neo4j Desktop và đảm bảo có ít nhất một database đang chạy"
  exit 1
fi

echo "📍 Tìm thấy cypher-shell tại: $NEO4J_PATH"

# Neo4j credentials
USER="neo4j"
PASSWORD="your_password"

# File cypher muốn chạy
SETUP_FILE="./models/3.2-graph-model.cypher"

# Kiểm tra file tồn tại
if [ ! -f "$SETUP_FILE" ]; then
  echo "❌ File $SETUP_FILE không tồn tại"
  exit 1
fi

# Chạy setup
echo "🚀 Đang chạy setup graph RBAC..."
"$NEO4J_PATH" -a bolt://localhost:7687 -u "$USER" -p "$PASSWORD" -f "$SETUP_FILE"

echo "✅ Graph RBAC setup completed!"