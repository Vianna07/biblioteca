#!/bin/bash
# dump.sh - Faz o dump do banco biblioteca

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

docker exec mariadb_lib mariadb-dump -u root -p"$(docker exec mariadb_lib printenv MARIADB_ROOT_PASSWORD)" --databases biblioteca > "$SCRIPT_DIR/dump/database.sql"

echo "Dump realizado com sucesso em $SCRIPT_DIR/dump/database.sql"
