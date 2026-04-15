#!/bin/bash
# init.sh - Escolhe automaticamente entre dump e main.sql para inicializar o banco
# Executado pelo docker-entrypoint-initdb.d na primeira subida do container

if [ -f /dump/database.sql ]; then
    echo "[init] Dump encontrado. Restaurando banco a partir de database.sql..."
    mariadb -u root -p"$MARIADB_ROOT_PASSWORD" < /dump/database.sql
else
    echo "[init] Dump não encontrado. Executando main.sql..."
    mariadb -u root -p"$MARIADB_ROOT_PASSWORD" < /scripts/main.sql
fi
