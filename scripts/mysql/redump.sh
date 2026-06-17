#!/bin/bash
# redump.sh -- Reinicializa o MySQL e gera dump atualizado
set -e

CONTAINER="mysql_lib"
PASS="${MYSQL_ROOT_PASSWORD:-root}"
DUMP_FILE="$(dirname "$0")/dump/database.sql"

echo "[mysql-redump] Dropando banco biblioteca..."
docker exec "$CONTAINER" mysql -uroot -p"$PASS" -e "DROP DATABASE IF EXISTS biblioteca;" 2>/dev/null

echo "[mysql-redump] Re-executando main.sql..."
docker exec -i "$CONTAINER" mysql -uroot -p"$PASS" < "$(dirname "$0")/main.sql" 2>/dev/null

echo "[mysql-redump] Gerando dump..."
mkdir -p "$(dirname "$DUMP_FILE")"
docker exec "$CONTAINER" mysqldump -uroot -p"$PASS" --databases biblioteca --routines --no-tablespaces 2>/dev/null > "$DUMP_FILE"

echo "[mysql-redump] Dump atualizado em $DUMP_FILE"
