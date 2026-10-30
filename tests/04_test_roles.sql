-- Bukti soal no. 4: hak akses tiap user. Jalankan sebagai postgres
-- (SET ROLE meniru hak user tersebut). Baris [GAGAL DIHARAPKAN] harus ERROR
-- "permission denied" atau "must be owner".
\set ECHO queries

\echo '################ backend_dev (CRUD semua tabel) ################'
SET ROLE backend_dev;
SELECT current_user;
\echo '[OK] SELECT'
SELECT nim, nama FROM SALAM.mahasiswas ORDER BY id LIMIT 3;
\echo '[OK] INSERT'
INSERT INTO SALAM.mahasiswas (nim, nama, email, angkatan, ipk)
VALUES ('1230000020', 'Dibuat backend_dev', 'be@example.org', 2024, 3.10);
\echo '[OK] UPDATE'
UPDATE SALAM.mahasiswas SET ipk = 3.30 WHERE nim = '1230000020';
\echo '[OK] DELETE'
DELETE FROM SALAM.mahasiswas WHERE nim = '1230000020';
\echo '[GAGAL DIHARAPKAN] CREATE TABLE'
CREATE TABLE SALAM.tabel_liar (id int);
\echo '[GAGAL DIHARAPKAN] ALTER TABLE'
ALTER TABLE SALAM.mahasiswas ADD COLUMN catatan text;
\echo '[GAGAL DIHARAPKAN] DROP TABLE'
DROP TABLE SALAM.mahasiswas;
RESET ROLE;

\echo ''
\echo '################ bi_dev (hanya SELECT tabel/view) ################'
SET ROLE bi_dev;
SELECT current_user;
\echo '[OK] SELECT tabel'
SELECT nim, nama, ipk FROM SALAM.mahasiswas ORDER BY id LIMIT 3;
\echo '[OK] SELECT view'
SELECT * FROM SALAM.v_mahasiswas_ringkas ORDER BY nim LIMIT 3;
\echo '[GAGAL DIHARAPKAN] INSERT'
INSERT INTO SALAM.mahasiswas (nim, nama, angkatan) VALUES ('1230000030', 'Coba bi_dev', 2024);
\echo '[GAGAL DIHARAPKAN] UPDATE'
UPDATE SALAM.mahasiswas SET ipk = 4.00 WHERE nim = '1230000001';
\echo '[GAGAL DIHARAPKAN] DELETE'
DELETE FROM SALAM.mahasiswas WHERE nim = '1230000001';
\echo '[GAGAL DIHARAPKAN] CREATE TABLE'
CREATE TABLE SALAM.tabel_bi (id int);
\echo '[GAGAL DIHARAPKAN] CREATE TABLE di schema public'
CREATE TABLE public.tabel_bi (id int);
RESET ROLE;

\echo ''
\echo '################ data_engineer (CREATE/ALTER/DROP + CRUD) ################'
SET ROLE data_engineer;
SELECT current_user;
\echo '[OK] CREATE TABLE'
CREATE TABLE SALAM.staging_nilai (id int PRIMARY KEY, nim varchar(14), nilai numeric(5,2));
\echo '[OK] INSERT / UPDATE / SELECT / DELETE pada tabel baru'
INSERT INTO SALAM.staging_nilai VALUES (1, '1230000001', 88.50);
UPDATE SALAM.staging_nilai SET nilai = 90 WHERE id = 1;
SELECT * FROM SALAM.staging_nilai;
DELETE FROM SALAM.staging_nilai WHERE id = 1;
\echo '[OK] ALTER TABLE (MODIFY)'
ALTER TABLE SALAM.staging_nilai ADD COLUMN catatan text;
\echo '[OK] CRUD pada tabel mahasiswas'
INSERT INTO SALAM.mahasiswas (nim, nama, angkatan) VALUES ('1230000040', 'Dibuat data_engineer', 2024);
UPDATE SALAM.mahasiswas SET semester = 2 WHERE nim = '1230000040';
DELETE FROM SALAM.mahasiswas WHERE nim = '1230000040';
\echo '[OK] DROP TABLE'
DROP TABLE SALAM.staging_nilai;
\echo '[OK] DROP TABLE mahasiswas di dalam transaksi lalu ROLLBACK (data aman)'
BEGIN;
DROP TABLE SALAM.mahasiswas CASCADE;
ROLLBACK;
RESET ROLE;

\echo ''
\echo '################ Jejak audit: siapa melakukan apa ################'
SELECT audit_id, aksi, oleh, nim FROM SALAM.mahasiswas_audit ORDER BY audit_id;
