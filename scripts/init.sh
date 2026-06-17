#!/bin/bash
# init.sh - Inicializa o banco biblioteca no primeiro start do container
# Executado pelo docker-entrypoint-initdb.d

if [ -f /scripts/dump/database.sql ]; then
    echo "[init] Dump encontrado. Restaurando banco a partir de database.sql..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /scripts/dump/database.sql
else
    echo "[init] Dump nao encontrado. Executando main.sql..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /scripts/mysql/main.sql
fi
