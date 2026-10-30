# UTS Manajemen Basis Data - PostgreSQL + pgAdmin 4 pakai Docker

Nama : Athar Abdullah Rahmat
NIM  : 1247050096
Prodi: Informatika, UIN Sunan Gunung Djati Bandung

Repo ini isi pengerjaan Proyek 1 / UTS Manajemen Basis Data. Intinya menjalankan
PostgreSQL 15 dan pgAdmin 4 lewat Docker Compose, lalu bikin schema, tabel, dan
user dengan hak akses yang berbeda-beda.

## Cara jalanin

1. Salin template env lalu isi sendiri:
   ```
   copy .env.example .env
   ```
   Yang perlu diubah cuma `NAMA` dan `NIM3`. Punyaku `NAMA=athar` dan `NIM3=096`.
2. Nyalakan Docker Desktop, lalu:
   ```
   docker compose up -d
   docker compose ps
   ```
   Tunggu sampai `postgres_athar` statusnya healthy.

Kalau mau ulang dari nol (data dihapus dan skrip SQL dijalankan lagi):
```
docker compose down -v
docker compose up -d
```
Ini perlu karena skrip di `initdb/` cuma jalan sekali, waktu volume masih kosong.

## Kenapa .env tidak ada di repo

Isinya password, jadi sengaja aku masukkan ke `.gitignore`. Yang ada di repo
cuma `.env.example` sebagai contoh bentuknya.

## Akses

| Dari mana | Alamat |
|---|---|
| pgAdmin (browser) | http://localhost:44096 |
| pgAdmin ke PostgreSQL (dalam Docker) | host `postgres`, port `5432` |
| DBeaver (luar Docker) | host `localhost`, port `22096`, database `uts_mbd` |

Di pgAdmin hostnya `postgres`, bukan `localhost`, karena pgAdmin jalan di
kontainernya sendiri dan menemukan PostgreSQL lewat nama service di network
Docker. Port 22096 cuma dipakai dari luar Docker.

## Isi repo

- `docker-compose.yml` : dua service (`postgres_athar` dan `pgadmin_athar`), semua nilainya dari `.env`
- `initdb/00_init.sh` : dijalankan otomatis saat database pertama kali dibuat
- `sql/01_schema_salam.sql` : schema `salam`, tabel `mahasiswas`, tabel audit, view
- `sql/02_users_roles.sql` : user `backend_dev`, `bi_dev`, `data_engineer`
- `tests/` : skrip buat membuktikan constraint dan hak akses jalan

Bukti dijalankan dengan:
```
docker exec -i postgres_athar psql -U postgres -d uts_mbd -f /tests/03_test_constraints.sql
docker exec -i postgres_athar psql -U postgres -d uts_mbd -f /tests/04_test_roles.sql
```
Pesan ERROR di hasilnya memang diharapkan, itu tanda constraint dan hak akses
menolak aksi yang tidak boleh.

## Tambahan di luar soal

- Tabel `mahasiswas_audit` + trigger: setiap INSERT/UPDATE/DELETE di `mahasiswas`
  dicatat beserta user database yang melakukannya. Jadi kelihatan siapa
  (`backend_dev`, `data_engineer`, dst.) yang mengubah data.
- View `v_mahasiswas_ringkas`: menampilkan predikat berdasarkan IPK, dipakai
  untuk mengetes `bi_dev` bisa baca view.

## Catatan hak akses

`data_engineer` aku jadikan pemilik (owner) schema `salam`, karena di PostgreSQL
hak ALTER dan DROP cuma dimiliki owner, tidak bisa dikasih lewat GRANT biasa.
Sedangkan `backend_dev` dan `bi_dev` dikasih GRANT biasa, dan aku tambah
`ALTER DEFAULT PRIVILEGES` supaya tabel baru otomatis ikut aturan yang sama.

## Kendala yang sempat kejadian

- Waktu edit `01_schema_salam.sql`, aku sempat menaruh NIM dan namaku di dalam
  definisi kolom tabel, bukan di bagian `INSERT`. Hasilnya SQL tidak valid.
  Sudah dibalikkan dan datanya dipindah ke bagian `INSERT` di bawah.
- Login pgAdmin ke PostgreSQL sempat ditolak (`password authentication failed`).
  Ternyata password yang diketik kurang tepat, setelah diketik ulang berhasil.
