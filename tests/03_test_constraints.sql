-- Bukti soal no. 3: constraint bekerja. Jalankan sebagai postgres.
-- Baris bertanda [GAGAL DIHARAPKAN] memang harus menghasilkan ERROR.
\set ECHO queries
\echo '=== STRUKTUR TABEL ==='
\d SALAM.mahasiswas

\echo ''
\echo '=== [OK] INSERT valid ==='
INSERT INTO SALAM.mahasiswas (nim, nama, email, angkatan, semester, ipk)
VALUES ('1230000010', 'Uji Valid', 'uji.valid@example.org', 2023, 5, 3.75);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] PRIMARY KEY: id=1 sudah dipakai ==='
INSERT INTO SALAM.mahasiswas (id, nim, nama, angkatan)
OVERRIDING SYSTEM VALUE VALUES (1, '1230000011', 'Uji PK', 2023);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] UNIQUE: NIM duplikat ==='
INSERT INTO SALAM.mahasiswas (nim, nama, email, angkatan)
VALUES ('1230000010', 'Uji Duplikat NIM', 'lain@example.org', 2023);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] UNIQUE: email duplikat ==='
INSERT INTO SALAM.mahasiswas (nim, nama, email, angkatan)
VALUES ('1230000012', 'Uji Duplikat Email', 'uji.valid@example.org', 2023);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] CHECK: IPK 4.50 (> 4.00) ==='
INSERT INTO SALAM.mahasiswas (nim, nama, angkatan, ipk)
VALUES ('1230000013', 'Uji IPK', 2023, 4.50);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] CHECK: format NIM bukan angka ==='
INSERT INTO SALAM.mahasiswas (nim, nama, angkatan)
VALUES ('ABC123', 'Uji NIM Huruf', 2023);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] CHECK: semester 20 ==='
INSERT INTO SALAM.mahasiswas (nim, nama, angkatan, semester)
VALUES ('1230000014', 'Uji Semester', 2023, 20);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] CHECK: format email salah ==='
INSERT INTO SALAM.mahasiswas (nim, nama, email, angkatan)
VALUES ('1230000015', 'Uji Email', 'bukan-email', 2023);

\echo ''
\echo '=== [GAGAL DIHARAPKAN] NOT NULL: nama kosong ==='
INSERT INTO SALAM.mahasiswas (nim, nama, angkatan)
VALUES ('1230000016', NULL, 2023);

\echo ''
\echo '=== Hasil akhir: hanya baris valid yang masuk ==='
SELECT id, nim, nama, ipk FROM SALAM.mahasiswas ORDER BY id;

\echo ''
\echo '=== Log audit (fitur pembeda) ==='
SELECT audit_id, aksi, oleh, nim FROM SALAM.mahasiswas_audit ORDER BY audit_id;
