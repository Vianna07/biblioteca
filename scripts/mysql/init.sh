#!/bin/bash
# init.sh -- Inicializa o banco biblioteca no MySQL
set -e

echo "[mysql-init] Executando main.sql..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /scripts/mysql/main.sql

echo "[mysql-init] Banco biblioteca inicializado com sucesso!"
