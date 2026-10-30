-- =====================================================================
-- 01_schema_salam.sql  |  Soal no. 3
-- Schema SALAM + tabel mahasiswas (PK, UNIQUE, CHECK) + fitur pembeda
-- Catatan: PostgreSQL melipat identifier tanpa tanda kutip ke huruf kecil,
-- jadi SALAM tersimpan sebagai "salam".
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS SALAM;

CREATE TABLE SALAM.mahasiswas (
    id         BIGINT GENERATED ALWAYS AS IDENTITY,
    nim        VARCHAR(14)  NOT NULL,
    nama       VARCHAR(100) NOT NULL,
    email      VARCHAR(120),
    angkatan   SMALLINT     NOT NULL,
    semester   SMALLINT     NOT NULL DEFAULT 1,
    ipk        NUMERIC(3,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),

    -- PRIMARY KEY
    CONSTRAINT pk_mahasiswas        PRIMARY KEY (id),
    -- UNIQUE: satu NIM / satu email hanya boleh dipakai satu mahasiswa
    CONSTRAINT uq_mahasiswas_nim    UNIQUE (nim),
    CONSTRAINT uq_mahasiswas_email  UNIQUE (email),
    -- CHECK
    CONSTRAINT ck_mahasiswas_nim_format  CHECK (nim ~ '^[0-9]{10,14}$'),
    CONSTRAINT ck_mahasiswas_ipk_range   CHECK (ipk BETWEEN 0.00 AND 4.00),
    CONSTRAINT ck_mahasiswas_semester    CHECK (semester BETWEEN 1 AND 14),
    CONSTRAINT ck_mahasiswas_angkatan    CHECK (angkatan BETWEEN 2000 AND 2100),
    CONSTRAINT ck_mahasiswas_email_format CHECK (email IS NULL OR email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

COMMENT ON TABLE SALAM.mahasiswas IS 'Data mahasiswa - Proyek 1 UTS Manajemen Basis Data';

-- ---------------------------------------------------------------------
-- FITUR PEMBEDA 1: tabel audit + trigger.
-- Setiap INSERT/UPDATE/DELETE pada mahasiswas dicatat beserta user DB
-- yang melakukannya (current_user). Berguna sebagai bukti di soal no. 4.
-- ---------------------------------------------------------------------
CREATE TABLE SALAM.mahasiswas_audit (
    audit_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    waktu      TIMESTAMPTZ NOT NULL DEFAULT now(),
    aksi       TEXT        NOT NULL,
    oleh       TEXT        NOT NULL,
    nim        VARCHAR(14),
    data_lama  JSONB,
    data_baru  JSONB
);

CREATE OR REPLACE FUNCTION SALAM.fn_audit_mahasiswas()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO SALAM.mahasiswas_audit (aksi, oleh, nim, data_baru)
        VALUES (TG_OP, current_user, NEW.nim, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO SALAM.mahasiswas_audit (aksi, oleh, nim, data_lama, data_baru)
        VALUES (TG_OP, current_user, NEW.nim, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSE
        INSERT INTO SALAM.mahasiswas_audit (aksi, oleh, nim, data_lama)
        VALUES (TG_OP, current_user, OLD.nim, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER trg_audit_mahasiswas
AFTER INSERT OR UPDATE OR DELETE ON SALAM.mahasiswas
FOR EACH ROW EXECUTE FUNCTION SALAM.fn_audit_mahasiswas();

-- ---------------------------------------------------------------------
-- FITUR PEMBEDA 2: view dengan predikat IPK (dipakai untuk bukti bi_dev
-- yang boleh SELECT ke table DAN view).
-- ---------------------------------------------------------------------
CREATE VIEW SALAM.v_mahasiswas_ringkas AS
SELECT nim,
       nama,
       angkatan,
       semester,
       ipk,
       CASE
           WHEN ipk >= 3.51 THEN 'Cum Laude'
           WHEN ipk >= 3.00 THEN 'Sangat Memuaskan'
           WHEN ipk >= 2.50 THEN 'Memuaskan'
           ELSE 'Perlu Pembinaan'
       END AS predikat
FROM SALAM.mahasiswas;


INSERT INTO SALAM.mahasiswas (nim, nama, email, angkatan, semester, ipk) VALUES
    ('1247050096', 'Athar Abdullah Rahmat', 'atharabdulahr@gmail.com', 2024, 5, 3.60),
    ('1230000001', 'Contoh Satu',   'contoh1@example.org', 2023, 5, 3.20),
    ('1230000002', 'Contoh Dua',    'contoh2@example.org', 2024, 3, 2.80);
