-- =====================================================================
-- 02_users_roles.sql  |  Soal no. 4
-- Dijalankan lewat psql dengan variabel :backend_pw, :bi_pw, :de_pw, :dbname
-- (diisi oleh initdb/00_init.sh dari file .env).
-- =====================================================================

-- 1) Buat user (role dengan hak LOGIN) -----------------------------------
CREATE ROLE backend_dev   LOGIN PASSWORD :'backend_pw';
CREATE ROLE bi_dev        LOGIN PASSWORD :'bi_pw';
CREATE ROLE data_engineer LOGIN PASSWORD :'de_pw';

-- 2) Kunci schema public: di PG < 15 semua user boleh CREATE di sini, itu
--    akan merusak bukti "bi_dev hanya boleh SELECT".
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 3) data_engineer menjadi PEMILIK (owner) schema SALAM beserta isinya.
--    Di PostgreSQL, ALTER dan DROP sebuah objek hanya boleh dilakukan owner
--    (atau superuser). GRANT biasa tidak punya hak "DROP", jadi ownership
--    adalah cara yang benar untuk memberi CREATE/MODIFY/DROP.
ALTER SCHEMA SALAM OWNER TO data_engineer;

DO $$
DECLARE r record;
BEGIN
    FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'salam' LOOP
        EXECUTE format('ALTER TABLE salam.%I OWNER TO data_engineer', r.tablename);
    END LOOP;
    FOR r IN SELECT viewname FROM pg_views WHERE schemaname = 'salam' LOOP
        EXECUTE format('ALTER VIEW salam.%I OWNER TO data_engineer', r.viewname);
    END LOOP;
    FOR r IN SELECT p.oid::regprocedure AS sig
             FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
             WHERE n.nspname = 'salam' LOOP
        EXECUTE format('ALTER FUNCTION %s OWNER TO data_engineer', r.sig);
    END LOOP;
END $$;

-- data_engineer juga boleh membuat schema baru di database ini
GRANT CREATE ON DATABASE :"dbname" TO data_engineer;

-- 4) backend_dev: CRUD semua tabel di schema SALAM --------------------------
GRANT USAGE ON SCHEMA SALAM TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SALAM TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA SALAM TO backend_dev;

-- 5) bi_dev: hanya SELECT (tabel + view) ------------------------------------
GRANT USAGE ON SCHEMA SALAM TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA SALAM TO bi_dev;   -- termasuk view

-- 6) data_engineer: CRUD (sebagai owner ia sudah punya semua hak di atas
--    objek miliknya; GRANT eksplisit ini untuk dokumentasi/kejelasan).
GRANT USAGE, CREATE ON SCHEMA SALAM TO data_engineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SALAM TO data_engineer;

-- 7) Default privileges: objek BARU yang dibuat nanti otomatis ikut aturan.
--    Berlaku untuk objek buatan data_engineer dan buatan postgres.
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA SALAM
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA SALAM
    GRANT SELECT ON TABLES TO bi_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA SALAM
    GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA SALAM
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev, data_engineer;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA SALAM
    GRANT SELECT ON TABLES TO bi_dev;
