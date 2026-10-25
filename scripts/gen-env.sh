#!/usr/bin/env bash
# Sinh file .env voi mat khau ngau nhien manh (24 ky tu chu + so).
# Dung:  ./scripts/gen-env.sh        (khong ghi de .env neu da co)
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  echo ".env da ton tai - khong ghi de. Xoa file neu muon sinh lai."
  exit 0
fi

rand() { LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-24}"; }

cat > .env <<EOT
TZ=Asia/Ho_Chi_Minh

MYSQL_DATABASE=recipe_db
MYSQL_ROOT_PASSWORD=$(rand 24)
APP_DB_USER=recipe_app
APP_DB_PASSWORD=$(rand 24)

SESSION_SECRET=$(rand 48)
ADMIN_USERNAME=admin
ADMIN_PASSWORD=$(rand 20)

EXPORTER_DB_PASSWORD=$(rand 24)
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$(rand 20)
EOT
chmod 600 .env
echo "Da tao .env. Xem mat khau dang nhap bang: grep -E 'ADMIN' .env"
