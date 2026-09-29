#!/bin/sh
set -eu

echo "Restaurando vendasx.backup..."
pg_restore \
  --username="$POSTGRES_USER" \
  --dbname="$POSTGRES_DB" \
  --no-owner \
  --no-privileges \
  --exit-on-error \
  --single-transaction \
  /backups/vendasx.backup
echo "Backup restaurado com sucesso."
