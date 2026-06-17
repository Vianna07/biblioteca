#!/bin/bash
# redump.sh - Recria o dump do banco biblioteca (MySQL)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASSWORD="$(docker exec mysql_lib printenv MYSQL_ROOT_PASSWORD)"

echo "[redump] Dropando banco biblioteca..."
docker exec mysql_lib mysql -u root -p"$PASSWORD" -e "DROP DATABASE IF EXISTS biblioteca;" 2>/dev/null

echo "[redump] Re-executando main.sql..."
docker exec -i mysql_lib mysql -u root -p"$PASSWORD" < "$SCRIPT_DIR/mysql/main.sql" 2>/dev/null

echo "[redump] Gerando dump..."
docker exec mysql_lib mysqldump -u root -p"$PASSWORD" --databases biblioteca --routines --no-tablespaces 2>/dev/null > "$SCRIPT_DIR/dump/database.sql"

echo "[redump] Dump atualizado em $SCRIPT_DIR/dump/database.sql"
