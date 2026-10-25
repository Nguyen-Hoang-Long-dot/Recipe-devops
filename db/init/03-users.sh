#!/bin/bash
# Hardening CSDL - nguyen tac "quyen toi thieu" (least privilege):
#   * recipe_app : chi SELECT/INSERT/UPDATE/DELETE tren dung 1 database (khong DDL, khong FILE, khong GRANT)
#   * exporter   : chi PROCESS + REPLICATION CLIENT (+ SELECT performance_schema) de Prometheus doc metrics
# Mat khau lay tu bien moi truong (file .env), khong hard-code.
set -e

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOSQL
CREATE USER '${APP_DB_USER}'@'%' IDENTIFIED BY '${APP_DB_PASSWORD}';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${MYSQL_DATABASE}\`.* TO '${APP_DB_USER}'@'%';

CREATE USER 'exporter'@'%' IDENTIFIED BY '${EXPORTER_DB_PASSWORD}' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';

FLUSH PRIVILEGES;
EOSQL
