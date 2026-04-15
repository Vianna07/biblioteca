#!/bin/bash
# redump.sh - Recria o dump do banco biblioteca
# Dropa o banco, re-executa o main.sql e gera um novo database.sql

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PASSWORD="$(docker exec mariadb_lib printenv MARIADB_ROOT_PASSWORD)"

echo "[redump] Dropando banco biblioteca..."
docker exec mariadb_lib mariadb -u root -p"$PASSWORD" -e "DROP DATABASE IF EXISTS biblioteca;"

echo "[redump] Re-executando main.sql..."
docker exec mariadb_lib mariadb -u root -p"$PASSWORD" -e "SOURCE /scripts/main.sql"

echo "[redump] Gerando dump..."
docker exec mariadb_lib mariadb-dump -u root -p"$PASSWORD" --databases biblioteca > "$PROJECT_ROOT/database.sql"

echo "[redump] Dump atualizado em $PROJECT_ROOT/database.sql"
