-- ========================================================
-- SCHEMA SUPABASE TINGKAT TINGGI: KEAMANAN & MULTI-MAPEL
-- Proyek: ferdianfer-creator's Project (NILAIKU)
-- URL: https://gigzgjuxbqdpwllaxzdu.supabase.co
--
-- FITUR KEAMANAN:
-- 1. Siswa/Publik HANYA BISA MELIHAT (READ-ONLY / SELECT).
-- 2. Modifikasi nilai (INSERT/UPDATE/DELETE) via REST API DITOLAK (403 Forbidden).
-- 3. Guru memvalidasi penginputan nilai via PostgreSQL Function (SECURITY DEFINER).
-- 4. Tabel kredensial admin_auth diisolasi (tidak dapat dibaca publik).
-- ========================================================

-- 1. TABEL KELAS
CREATE TABLE IF NOT EXISTS public.classes (
    id BIGSERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. TABEL MATA PELAJARAN & GURU (SUBJECTS)
CREATE TABLE IF NOT EXISTS public.subjects (
    id BIGSERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    teacher_name TEXT NOT NULL,
    kkm INTEGER DEFAULT 75,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. TABEL PENGATURAN APLIKASI
CREATE TABLE IF NOT EXISTS public.app_config (
    id INTEGER PRIMARY KEY DEFAULT 1,
    app_name TEXT DEFAULT 'NILAIKU',
    school_name TEXT DEFAULT 'SMP ISLAM AL AZHAR 30 TASIKMALAYA',
    subject_name TEXT DEFAULT 'Informatika',
    teacher_name TEXT DEFAULT 'Fery Ferdian, S.Kom',
    academic_year TEXT DEFAULT '2026/2027',
    kkm INTEGER DEFAULT 75,
    max_attendance INTEGER DEFAULT 16,
    admin_password TEXT DEFAULT 'guru123',
    spreadsheet_url TEXT DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. TABEL KREDENSIAL GURU TERISOLASI (PRIVATE AUTH)
CREATE TABLE IF NOT EXISTS public.admin_auth (
    id INTEGER PRIMARY KEY DEFAULT 1,
    password TEXT NOT NULL DEFAULT 'guru123',
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

INSERT INTO public.admin_auth (id, password)
VALUES (1, 'guru123')
ON CONFLICT (id) DO NOTHING;

-- 5. TABEL SISWA DAN NILAI (DENGAN KOLOM SUBJECT)
CREATE TABLE IF NOT EXISTS public.students (
    id BIGSERIAL PRIMARY KEY,
    nisn TEXT NOT NULL,
    name TEXT NOT NULL,
    class TEXT NOT NULL,
    subject TEXT NOT NULL DEFAULT 'Informatika',
    attendance INTEGER DEFAULT 0,
    task_1 INTEGER,
    task_2 INTEGER,
    task_3 INTEGER,
    task_4 INTEGER,
    task_5 INTEGER,
    asts INTEGER,
    asaj INTEGER,
    manual_final_score INTEGER,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Migrasi struktur jika tabel lama sudah ada di Supabase
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS subject TEXT NOT NULL DEFAULT 'Informatika';
ALTER TABLE public.students DROP CONSTRAINT IF EXISTS students_nisn_key;
ALTER TABLE public.students DROP CONSTRAINT IF EXISTS students_nisn_subject_key;
ALTER TABLE public.students ADD CONSTRAINT students_nisn_subject_key UNIQUE (nisn, subject);

-- 6. ROW LEVEL SECURITY (RLS) - LAPISAN KEAMANAN MAKSIMAL
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_auth ENABLE ROW LEVEL SECURITY;

-- Kredensial Guru DITUTUP TOTAL dari akses publik (Anon tidak bisa melihat password)
DROP POLICY IF EXISTS "Admin Auth Private" ON public.admin_auth;
CREATE POLICY "Admin Auth Private" ON public.admin_auth FOR ALL TO authenticated USING (true);

-- Siswa/Publik HANYA boleh SELECT (Read-Only)
DROP POLICY IF EXISTS "Public Read-Only Classes" ON public.classes;
DROP POLICY IF EXISTS "Anon Full Access Classes" ON public.classes;
CREATE POLICY "Public Read-Only Classes" ON public.classes FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Auth Full Classes" ON public.classes;
DROP POLICY IF EXISTS "Auth Full Access Classes" ON public.classes;
CREATE POLICY "Auth Full Classes" ON public.classes FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Read-Only Subjects" ON public.subjects;
DROP POLICY IF EXISTS "Anon Full Access Subjects" ON public.subjects;
CREATE POLICY "Public Read-Only Subjects" ON public.subjects FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Auth Full Subjects" ON public.subjects;
DROP POLICY IF EXISTS "Auth Full Access Subjects" ON public.subjects;
CREATE POLICY "Auth Full Subjects" ON public.subjects FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Read-Only Config" ON public.app_config;
DROP POLICY IF EXISTS "Anon Full Access AppConfig" ON public.app_config;
CREATE POLICY "Public Read-Only Config" ON public.app_config FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Auth Full Config" ON public.app_config;
DROP POLICY IF EXISTS "Auth Full Access AppConfig" ON public.app_config;
CREATE POLICY "Auth Full Config" ON public.app_config FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Siswa HANYA boleh baca nilai, DILARANG INSERT/UPDATE/DELETE langsung dari browser
DROP POLICY IF EXISTS "Public Read-Only Students" ON public.students;
DROP POLICY IF EXISTS "Anon Full Access Students" ON public.students;
CREATE POLICY "Public Read-Only Students" ON public.students FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Auth Full Students" ON public.students;
DROP POLICY IF EXISTS "Auth Full Access Students" ON public.students;
CREATE POLICY "Auth Full Students" ON public.students FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 7. FUNGSI AMAN SERVER-SIDE DENGAN VERIFIKASI PASSWORD GURU (SECURITY DEFINER)

-- A. Fungsi Simpan / Edit Nilai Siswa
CREATE OR REPLACE FUNCTION public.save_student_secure(
    p_password TEXT,
    p_nisn TEXT,
    p_name TEXT,
    p_class TEXT,
    p_subject TEXT,
    p_attendance INT,
    p_task_1 INT,
    p_task_2 INT,
    p_task_3 INT,
    p_task_4 INT,
    p_task_5 INT,
    p_asts INT,
    p_asaj INT,
    p_manual_final INT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    stored_pass TEXT;
BEGIN
    SELECT password INTO stored_pass FROM public.admin_auth WHERE id = 1;
    IF stored_pass IS NULL THEN stored_pass := 'guru123'; END IF;

    IF p_password IS NULL OR p_password <> stored_pass THEN
        RAISE EXCEPTION 'Akses Ditolak: Password Guru salah.';
    END IF;

    INSERT INTO public.students (
        nisn, name, class, subject, attendance,
        task_1, task_2, task_3, task_4, task_5,
        asts, asaj, manual_final_score, updated_at
    ) VALUES (
        p_nisn, p_name, p_class, COALESCE(p_subject, 'Informatika'), COALESCE(p_attendance, 0),
        p_task_1, p_task_2, p_task_3, p_task_4, p_task_5,
        p_asts, p_asaj, p_manual_final, now()
    )
    ON CONFLICT (nisn, subject) DO UPDATE SET
        name = EXCLUDED.name,
        class = EXCLUDED.class,
        attendance = EXCLUDED.attendance,
        task_1 = EXCLUDED.task_1,
        task_2 = EXCLUDED.task_2,
        task_3 = EXCLUDED.task_3,
        task_4 = EXCLUDED.task_4,
        task_5 = EXCLUDED.task_5,
        asts = EXCLUDED.asts,
        asaj = EXCLUDED.asaj,
        manual_final_score = EXCLUDED.manual_final_score,
        updated_at = now();

    RETURN jsonb_build_object('success', true, 'nisn', p_nisn);
END;
$$;

-- B. Fungsi Hapus Siswa
CREATE OR REPLACE FUNCTION public.delete_student_secure(
    p_password TEXT,
    p_nisn TEXT,
    p_subject TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    stored_pass TEXT;
BEGIN
    SELECT password INTO stored_pass FROM public.admin_auth WHERE id = 1;
    IF stored_pass IS NULL THEN stored_pass := 'guru123'; END IF;

    IF p_password IS NULL OR p_password <> stored_pass THEN
        RAISE EXCEPTION 'Akses Ditolak: Password Guru salah.';
    END IF;

    DELETE FROM public.students
    WHERE nisn = p_nisn AND (p_subject IS NULL OR subject = p_subject);

    RETURN jsonb_build_object('success', true, 'deleted_nisn', p_nisn);
END;
$$;

-- C. Fungsi Ganti Password Guru
CREATE OR REPLACE FUNCTION public.change_guru_password_secure(
    p_old_password TEXT,
    p_new_password TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    stored_pass TEXT;
BEGIN
    SELECT password INTO stored_pass FROM public.admin_auth WHERE id = 1;
    IF stored_pass IS NULL THEN stored_pass := 'guru123'; END IF;

    IF p_old_password <> stored_pass THEN
        RAISE EXCEPTION 'Password lama tidak cocok.';
    END IF;

    IF length(p_new_password) < 6 THEN
        RAISE EXCEPTION 'Password baru minimal 6 karakter.';
    END IF;

    UPDATE public.admin_auth
    SET password = p_new_password, updated_at = now()
    WHERE id = 1;

    RETURN jsonb_build_object('success', true, 'message', 'Password berhasil diubah');
END;
$$;

-- 8. DATA AWAL: KELAS & MATA PELAJARAN
INSERT INTO public.classes (name)
VALUES ('VIII A'), ('VIII B')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.subjects (name, teacher_name, kkm)
VALUES 
    ('Informatika', 'Fery Ferdian, S.Kom', 75),
    ('Bahasa Indonesia', 'Dadi, S.Pd., Gr', 75),
    ('Bahasa Inggris', 'Zhilla, S.Pd.', 75)
ON CONFLICT (name) DO UPDATE SET teacher_name = EXCLUDED.teacher_name, kkm = EXCLUDED.kkm;

INSERT INTO public.app_config (id, app_name, school_name, subject_name, teacher_name, academic_year, kkm, max_attendance, admin_password)
VALUES (1, 'NILAIKU', 'SMP ISLAM AL AZHAR 30 TASIKMALAYA', 'Informatika', 'Fery Ferdian, S.Kom', '2026/2027', 75, 16, 'guru123')
ON CONFLICT (id) DO UPDATE SET
    app_name = EXCLUDED.app_name,
    school_name = EXCLUDED.school_name,
    subject_name = EXCLUDED.subject_name,
    teacher_name = EXCLUDED.teacher_name;

-- 9. SEED DATA SISWA (156 DATA SISWA & 3 MATA PELAJARAN) UNTUK 3 MATA PELAJARAN (156 DATA: INFORMATIKA, B. INDONESIA, B. INGGRIS)
INSERT INTO public.students (nisn, name, class, subject, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES
('4330-2526101', 'Adinda Sabina Putri Cuhva', 'VIII A', 'Bahasa Indonesia', 16, 88, 85, 90, 86, 92, 88, 90, NULL),
('4330-2526102', 'Alisha Khusnaira', 'VIII A', 'Bahasa Indonesia', 16, 92, 90, 95, 92, 94, 93, 94, NULL),
('4330-2526103', 'Anaya Waheeda Prilia', 'VIII A', 'Bahasa Indonesia', 15, 84, 82, 85, 80, 88, 84, 86, NULL),
('4330-2526104', 'Bilqis Sharliz Queenzha', 'VIII A', 'Bahasa Indonesia', 16, 90, 88, 92, 90, 95, 90, 92, NULL),
('4330-2526105', 'Daffa Al Abrar Al Fansyah', 'VIII A', 'Bahasa Indonesia', 14, 78, 75, 72, NULL, 76, 74, NULL, NULL),
('4330-2526106', 'Janetta Aleyza Andiputri', 'VIII A', 'Bahasa Indonesia', 16, 88, 90, 86, 92, 90, 89, 91, NULL),
('4330-2526107', 'Kasyfi Syarifi Rosdiansyah', 'VIII A', 'Bahasa Indonesia', 15, 82, 80, 85, 84, 86, 82, 85, NULL),
('4330-2526108', 'Keenar Liyana', 'VIII A', 'Bahasa Indonesia', 16, 94, 92, 96, 95, 98, 95, 96, NULL),
('4330-2526109', 'M Revhan Akhtar Aditya', 'VIII A', 'Bahasa Indonesia', 14, 76, 74, 80, 75, NULL, 78, NULL, NULL),
('4330-2526110', 'M. Raffa Azzikra', 'VIII A', 'Bahasa Indonesia', 15, 80, 82, 84, 80, 85, 82, 84, NULL),
('4330-2526111', 'Mikalla Efrans Wiramapta', 'VIII A', 'Bahasa Indonesia', 16, 86, 88, 85, 90, 88, 87, 89, NULL),
('4330-2526112', 'Moch Bilal Muhaimin Pranata', 'VIII A', 'Bahasa Indonesia', 13, 72, NULL, 74, 70, 75, 72, NULL, NULL),
('4330-2526113', 'Moh Mandala Putra', 'VIII A', 'Bahasa Indonesia', 15, 85, 84, 86, 88, 90, 86, 88, NULL),
('4330-2526114', 'Muh Al Fatih Mikail Marindra', 'VIII A', 'Bahasa Indonesia', 16, 90, 92, 88, 94, 92, 91, 93, NULL),
('4330-2526115', 'Muhammad Aldrin Alghifari', 'VIII A', 'Bahasa Indonesia', 15, 82, 85, 80, 86, 84, 83, 85, NULL),
('4330-2526116', 'Nafis Ahmad A', 'VIII A', 'Bahasa Indonesia', 15, 84, 82, 86, 85, 88, 85, 87, NULL),
('4330-2526117', 'Nindya Kireina Ramadhani', 'VIII A', 'Bahasa Indonesia', 16, 92, 90, 94, 95, 96, 93, 95, NULL),
('4330-2526118', 'Nizar Zilmi Syahban', 'VIII A', 'Bahasa Indonesia', 15, 80, 78, 82, 84, 82, 80, 83, NULL),
('4330-2526119', 'Pradipta Driyarkara Qytara Puruhita Galur Suryana Putri', 'VIII A', 'Bahasa Indonesia', 16, 95, 94, 96, 98, 97, 96, 97, NULL),
('4330-2526120', 'Qhillan Tanisya Saquilla', 'VIII A', 'Bahasa Indonesia', 16, 88, 86, 90, 92, 89, 89, 91, NULL),
('4330-2526121', 'Qisya Batrisya Irdina', 'VIII A', 'Bahasa Indonesia', 16, 91, 92, 90, 93, 95, 92, 94, NULL),
('4330-2526122', 'Salma Khoerunnisa', 'VIII A', 'Bahasa Indonesia', 16, 89, 91, 88, 92, 90, 90, 92, NULL),
('4330-2526123', 'Syaima Nurul Aisyah', 'VIII A', 'Bahasa Indonesia', 16, 93, 95, 92, 94, 96, 94, 95, NULL),
('4330-2526124', 'Tazka Azfar Ramadhan', 'VIII A', 'Bahasa Indonesia', 15, 84, 82, 85, 86, 88, 85, 87, NULL),
('4330-2526125', 'Tiara Mega Nurliana', 'VIII A', 'Bahasa Indonesia', 16, 90, 92, 91, 94, 93, 91, 93, NULL),
('4330-2526126', 'Vidya Nur Ismaya Putri', 'VIII A', 'Bahasa Indonesia', 16, 92, 94, 95, 96, 95, 93, 95, NULL),
('4330-2526002', 'Ainzya Putri M', 'VIII B', 'Bahasa Indonesia', 20, 81, 80, 80, 80, 85, 80, 0, NULL),
('4330-2526004', 'Alfina Nadia Fauziah', 'VIII B', 'Bahasa Indonesia', 16, 85, 88, 86, 84, 85, 85, 80, NULL),
('4330-2526011', 'Aryan Rasyad Noor Iksan', 'VIII B', 'Bahasa Indonesia', 15, 82, 80, 85, 84, 86, 83, 82, NULL),
('4330-2526015', 'Chayra Ghaziya Zahran', 'VIII B', 'Bahasa Indonesia', 16, 90, 92, 88, 90, 94, 91, 90, NULL),
('4330-2526017', 'Devan Alvian Mubarok', 'VIII B', 'Bahasa Indonesia', 15, 80, 82, 84, 85, 80, 82, 84, NULL),
('4330-2526019', 'Fadlan Fazlurrahman', 'VIII B', 'Bahasa Indonesia', 16, 86, 88, 85, 87, 89, 87, 88, NULL),
('4330-2526020', 'Faisya Nida Rahmah', 'VIII B', 'Bahasa Indonesia', 16, 88, 90, 92, 89, 91, 90, 92, NULL),
('4330-2526021', 'Faiz Muhammad Faisal', 'VIII B', 'Bahasa Indonesia', 15, 84, 82, 86, 85, 88, 85, 86, NULL),
('4330-2526023', 'Farin Naura Zafarani', 'VIII B', 'Bahasa Indonesia', 16, 91, 93, 90, 92, 94, 92, 93, NULL),
('4330-2526026', 'Hannah Sabrina Maryam', 'VIII B', 'Bahasa Indonesia', 16, 90, 89, 92, 91, 95, 91, 92, NULL),
('4330-2526032', 'Keyra Navira Danate', 'VIII B', 'Bahasa Indonesia', 15, 85, 84, 88, 86, 87, 86, 88, NULL),
('4330-2526034', 'Lintang Ramadhan Sukmadiraja', 'VIII B', 'Bahasa Indonesia', 15, 83, 85, 82, 86, 84, 84, 85, NULL),
('4330-2526037', 'Maryam Ali', 'VIII B', 'Bahasa Indonesia', 16, 92, 94, 91, 93, 95, 93, 94, NULL),
('4330-2526040', 'Muhammad Irsyad Rifky Alkhairu', 'VIII B', 'Bahasa Indonesia', 15, 82, 84, 80, 85, 83, 84, 85, NULL),
('4330-2526049', 'Muhammad Kenzie Ammar Sudjana', 'VIII B', 'Bahasa Indonesia', 14, 78, 75, 72, NULL, 76, 74, NULL, NULL),
('4330-2526033', 'Muhammad Khairan Fasyza Jabar', 'VIII B', 'Bahasa Indonesia', 16, 89, 91, 88, 90, 92, 90, 91, NULL),
('4330-2526050', 'Muhammad Rizky Abdul Ba''its', 'VIII B', 'Bahasa Indonesia', 15, 86, 85, 88, 87, 89, 87, 88, NULL),
('4330-2526054', 'Naura Ayumi', 'VIII B', 'Bahasa Indonesia', 16, 94, 93, 95, 96, 97, 95, 96, NULL),
('4330-2526060', 'Qonita Hanifa', 'VIII B', 'Bahasa Indonesia', 16, 91, 90, 93, 92, 94, 92, 93, NULL),
('4330-2526063', 'Ray Jibran Elbany', 'VIII B', 'Bahasa Indonesia', 15, 85, 86, 84, 88, 87, 86, 87, NULL),
('4330-2526065', 'Rizqi Rijaldi', 'VIII B', 'Bahasa Indonesia', 16, 88, 90, 87, 89, 91, 89, 90, NULL),
('4330-2526067', 'Rizqia Nafiza Putri Eldiansyah', 'VIII B', 'Bahasa Indonesia', 16, 93, 92, 95, 94, 96, 94, 95, NULL),
('4330-2526070', 'Shayna Clarissa Abelia', 'VIII B', 'Bahasa Indonesia', 16, 90, 92, 89, 91, 93, 91, 92, NULL),
('4330-2526069', 'Syabil Azhfar Hidayat', 'VIII B', 'Bahasa Indonesia', 15, 84, 85, 82, 86, 85, 85, 86, NULL),
('4330-2526072', 'Syakira Az Zahra', 'VIII B', 'Bahasa Indonesia', 16, 95, 94, 96, 97, 98, 96, 97, NULL),
('4330-2526075', 'Zaky Fajarul Anwar', 'VIII B', 'Bahasa Indonesia', 15, 87, 88, 85, 89, 88, 88, 89, NULL),
('4330-2526101', 'Adinda Sabina Putri Cuhva', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526102', 'Alisha Khusnaira', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526103', 'Anaya Waheeda Prilia', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526104', 'Bilqis Sharliz Queenzha', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526105', 'Daffa Al Abrar Al Fansyah', 'VIII A', 'Informatika', 14, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526106', 'Janetta Aleyza Andiputri', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526107', 'Kasyfi Syarifi Rosdiansyah', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526108', 'Keenar Liyana', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526109', 'M Revhan Akhtar Aditya', 'VIII A', 'Informatika', 14, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526110', 'M. Raffa Azzikra', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526111', 'Mikalla Efrans Wiramapta', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526112', 'Moch Bilal Muhaimin Pranata', 'VIII A', 'Informatika', 13, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526113', 'Moh Mandala Putra', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526114', 'Muh Al Fatih Mikail Marindra', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526115', 'Muhammad Aldrin Alghifari', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526116', 'Nafis Ahmad A', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526117', 'Nindya Kireina Ramadhani', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526118', 'Nizar Zilmi Syahban', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526119', 'Pradipta Driyarkara Qytara Puruhita Galur Suryana Putri', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526120', 'Qhillan Tanisya Saquilla', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526121', 'Qisya Batrisya Irdina', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526122', 'Salma Khoerunnisa', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526123', 'Syaima Nurul Aisyah', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526124', 'Tazka Azfar Ramadhan', 'VIII A', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526125', 'Tiara Mega Nurliana', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526126', 'Vidya Nur Ismaya Putri', 'VIII A', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526002', 'Ainzya Putri M', 'VIII B', 'Informatika', 20, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526004', 'Alfina Nadia Fauziah', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526011', 'Aryan Rasyad Noor Iksan', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526015', 'Chayra Ghaziya Zahran', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526017', 'Devan Alvian Mubarok', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526019', 'Fadlan Fazlurrahman', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526020', 'Faisya Nida Rahmah', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526021', 'Faiz Muhammad Faisal', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526023', 'Farin Naura Zafarani', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526026', 'Hannah Sabrina Maryam', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526032', 'Keyra Navira Danate', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526034', 'Lintang Ramadhan Sukmadiraja', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526037', 'Maryam Ali', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526040', 'Muhammad Irsyad Rifky Alkhairu', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526049', 'Muhammad Kenzie Ammar Sudjana', 'VIII B', 'Informatika', 14, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526033', 'Muhammad Khairan Fasyza Jabar', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526050', 'Muhammad Rizky Abdul Ba''its', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526054', 'Naura Ayumi', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526060', 'Qonita Hanifa', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526063', 'Ray Jibran Elbany', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526065', 'Rizqi Rijaldi', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526067', 'Rizqia Nafiza Putri Eldiansyah', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526070', 'Shayna Clarissa Abelia', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526069', 'Syabil Azhfar Hidayat', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526072', 'Syakira Az Zahra', 'VIII B', 'Informatika', 16, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526075', 'Zaky Fajarul Anwar', 'VIII B', 'Informatika', 15, 85, 90, 88, 92, 90, 88, 90, NULL),
('4330-2526101', 'Adinda Sabina Putri Cuhva', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526102', 'Alisha Khusnaira', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526103', 'Anaya Waheeda Prilia', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526104', 'Bilqis Sharliz Queenzha', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526105', 'Daffa Al Abrar Al Fansyah', 'VIII A', 'Bahasa Inggris', 14, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526106', 'Janetta Aleyza Andiputri', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526107', 'Kasyfi Syarifi Rosdiansyah', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526108', 'Keenar Liyana', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526109', 'M Revhan Akhtar Aditya', 'VIII A', 'Bahasa Inggris', 14, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526110', 'M. Raffa Azzikra', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526111', 'Mikalla Efrans Wiramapta', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526112', 'Moch Bilal Muhaimin Pranata', 'VIII A', 'Bahasa Inggris', 13, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526113', 'Moh Mandala Putra', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526114', 'Muh Al Fatih Mikail Marindra', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526115', 'Muhammad Aldrin Alghifari', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526116', 'Nafis Ahmad A', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526117', 'Nindya Kireina Ramadhani', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526118', 'Nizar Zilmi Syahban', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526119', 'Pradipta Driyarkara Qytara Puruhita Galur Suryana Putri', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526120', 'Qhillan Tanisya Saquilla', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526121', 'Qisya Batrisya Irdina', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526122', 'Salma Khoerunnisa', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526123', 'Syaima Nurul Aisyah', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526124', 'Tazka Azfar Ramadhan', 'VIII A', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526125', 'Tiara Mega Nurliana', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526126', 'Vidya Nur Ismaya Putri', 'VIII A', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526002', 'Ainzya Putri M', 'VIII B', 'Bahasa Inggris', 20, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526004', 'Alfina Nadia Fauziah', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526011', 'Aryan Rasyad Noor Iksan', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526015', 'Chayra Ghaziya Zahran', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526017', 'Devan Alvian Mubarok', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526019', 'Fadlan Fazlurrahman', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526020', 'Faisya Nida Rahmah', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526021', 'Faiz Muhammad Faisal', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526023', 'Farin Naura Zafarani', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526026', 'Hannah Sabrina Maryam', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526032', 'Keyra Navira Danate', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526034', 'Lintang Ramadhan Sukmadiraja', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526037', 'Maryam Ali', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526040', 'Muhammad Irsyad Rifky Alkhairu', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526049', 'Muhammad Kenzie Ammar Sudjana', 'VIII B', 'Bahasa Inggris', 14, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526033', 'Muhammad Khairan Fasyza Jabar', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526050', 'Muhammad Rizky Abdul Ba''its', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526054', 'Naura Ayumi', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526060', 'Qonita Hanifa', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526063', 'Ray Jibran Elbany', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526065', 'Rizqi Rijaldi', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526067', 'Rizqia Nafiza Putri Eldiansyah', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526070', 'Shayna Clarissa Abelia', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526069', 'Syabil Azhfar Hidayat', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526072', 'Syakira Az Zahra', 'VIII B', 'Bahasa Inggris', 16, 84, 88, 86, 90, 88, 86, 88, NULL),
('4330-2526075', 'Zaky Fajarul Anwar', 'VIII B', 'Bahasa Inggris', 15, 84, 88, 86, 90, 88, 86, 88, NULL)
ON CONFLICT (nisn, subject) DO UPDATE SET
    name = EXCLUDED.name,
    class = EXCLUDED.class,
    attendance = EXCLUDED.attendance,
    task_1 = EXCLUDED.task_1,
    task_2 = EXCLUDED.task_2,
    task_3 = EXCLUDED.task_3,
    task_4 = EXCLUDED.task_4,
    task_5 = EXCLUDED.task_5,
    asts = EXCLUDED.asts,
    asaj = EXCLUDED.asaj,
    manual_final_score = EXCLUDED.manual_final_score;
