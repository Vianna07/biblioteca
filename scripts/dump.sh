#!/bin/bash
# dump.sh - Faz o dump do banco biblioteca e salva na raiz do projeto

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

docker exec mariadb_lib mariadb-dump -u root -p"$(docker exec mariadb_lib printenv MARIADB_ROOT_PASSWORD)" biblioteca > "$PROJECT_ROOT/database.sql"

echo "Dump realizado com sucesso em $PROJECT_ROOT/database.sql"
