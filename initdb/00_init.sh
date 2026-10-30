#!/bin/bash
# Dijalankan otomatis oleh image postgres SATU KALI saat volume data masih kosong.
# Password user aplikasi dilempar ke SQL lewat variabel psql (-v) agar tidak
# tertulis (hardcode) di file .sql yang ikut di-push ke GitHub.
set -e

PSQL="psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --dbname $POSTGRES_DB"

echo ">>> [1/2] Membuat schema SALAM + tabel + data awal"
$PSQL -f /sql/01_schema_salam.sql

echo ">>> [2/2] Membuat user & hak akses"
$PSQL \
  -v backend_pw="$BACKEND_DEV_PASSWORD" \
  -v bi_pw="$BI_DEV_PASSWORD" \
  -v de_pw="$DATA_ENGINEER_PASSWORD" \
  -v dbname="$POSTGRES_DB" \
  -f /sql/02_users_roles.sql

echo ">>> Inisialisasi selesai"
