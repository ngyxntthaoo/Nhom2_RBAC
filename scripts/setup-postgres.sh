#!/bin/bash
set -e

# Biến cấu hình
CONTAINER_NAME=pg
DB_NAME=key_value
SQL_FILE=models/key-value/key-value-policy.sql
CONTAINER_PATH=/tmp/key-value-policy.sql

echo "📦 Copying SQL file into container..."
docker cp $SQL_FILE $CONTAINER_NAME:$CONTAINER_PATH

echo "🚀 Running SQL file in PostgreSQL..."
docker exec -i $CONTAINER_NAME psql -U postgres -d $DB_NAME -f $CONTAINER_PATH

echo "✅ PostgreSQL setup complete."