set -e

# Thư mục chứa file .cql trên host
HOST_CQL_DIR="/Users/thnhthao/Master/Ad-CSDL/RBAC-db/models"

# 1. Chạy container Cassandra, mount thư mục host vào /cql trong container
echo "🚀 Starting Cassandra container..."
docker run --name cassandra -p 9042:9042 -v "$HOST_CQL_DIR:/cql" -d cassandra:4.1

# 2. Chờ Cassandra khởi động (kiểm tra port 9042)
echo "⏳ Waiting for Cassandra to initialize..."
until docker exec cassandra cqlsh -e "DESCRIBE KEYSPACES;" >/dev/null 2>&1; do
  echo "   → Cassandra not ready yet. Retrying in 5s..."
  sleep 5
done

# 3. Tạo keyspace
echo "📦 Creating keyspace..."
docker exec -i cassandra cqlsh -e "CREATE KEYSPACE IF NOT EXISTS wide_column WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};"

# 4. Kiểm tra keyspaces
echo "🔍 Verifying keyspaces..."
docker exec -i cassandra cqlsh -e "DESCRIBE KEYSPACES;"

# 5. Kiểm tra file trong container
echo "📁 Checking mounted files..."
docker exec cassandra ls -la /cql/

# 6. Thực thi file CQL policy từ thư mục mounted
echo "📄 Applying wide-column policies..."
docker exec -i cassandra cqlsh -f /cql/3.2-wide-column.cql

echo "✅ Cassandra setup complete."
