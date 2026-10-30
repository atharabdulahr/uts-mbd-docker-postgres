# Proyek 1 / UTS Manajemen Basis Data - PostgreSQL + pgAdmin4 (Docker)

## Menjalankan
```bash
cp .env.example .env        # lalu edit NAMA dan NIM3 (3 digit terakhir NIM)
docker compose up -d
docker compose ps           # postgres_NAMA harus (healthy)
```
Reset total (hapus data & jalankan ulang init script):
`docker compose down -v && docker compose up -d`

## Akses
| Dari | Alamat |
|---|---|
| pgAdmin (browser) | http://localhost:44XXX  (login: PGADMIN_DEFAULT_EMAIL / PASSWORD di .env) |
| pgAdmin -> PostgreSQL (internal docker) | Host `postgres`, Port `5432` |
| DBeaver (eksternal docker) | Host `localhost`, Port `22XXX`, DB `uts_mbd`, user `postgres` |

## Bukti
```bash
docker exec -i postgres_NAMA psql -U postgres -d uts_mbd -f /tests/03_test_constraints.sql
docker exec -i postgres_NAMA psql -U postgres -d uts_mbd -f /tests/04_test_roles.sql
```
(Ganti NAMA sesuai .env. Pada soal 3 dan 4 pesan ERROR adalah hasil yang diharapkan.)

## Struktur
- `docker-compose.yml` - 2 service, semua nilai dari `.env`
- `.env.example` - template (`.env` asli di-gitignore)
- `initdb/00_init.sh` - dijalankan otomatis saat volume kosong
- `sql/01_schema_salam.sql` - schema SALAM, tabel mahasiswas, audit trigger, view
- `sql/02_users_roles.sql` - backend_dev, bi_dev, data_engineer
- `tests/` - skrip pembuktian
