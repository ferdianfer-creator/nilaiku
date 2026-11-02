-- ========================================================
-- SCHEMA DATABASE SUPABASE UNTUK NILAIKU (STUDENT TRACKER)
-- Proyek: ferdianfer-creator's Project
-- URL Supabase: https://qiqzgjuxbqdpwllaxzdu.supabase.co
-- ========================================================

-- 1. TABEL KELAS (CLASSES)
CREATE TABLE IF NOT EXISTS public.classes (
    id BIGSERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. TABEL PENGATURAN APLIKASI (APP_CONFIG)
CREATE TABLE IF NOT EXISTS public.app_config (
    id INTEGER PRIMARY KEY DEFAULT 1,
    app_name TEXT DEFAULT 'NILAIKU',
    school_name TEXT DEFAULT 'SMP ISLAM AL AZHAR 30 TASIKMALAYA',
    subject_name TEXT DEFAULT 'BAHASA INDONESIA',
    teacher_name TEXT DEFAULT 'Dadi, S.Pd., Gr',
    academic_year TEXT DEFAULT '2026/2027',
    kkm INTEGER DEFAULT 75,
    max_attendance INTEGER DEFAULT 16,
    admin_password TEXT DEFAULT 'guru123',
    spreadsheet_url TEXT DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. TABEL SISWA DAN NILAI (STUDENTS)
CREATE TABLE IF NOT EXISTS public.students (
    id BIGSERIAL PRIMARY KEY,
    nisn TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    class TEXT NOT NULL,
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

-- 4. OTOMATISASI UPDATED_AT DENGAN TRIGGER
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_students_updated_at ON public.students;
CREATE TRIGGER trigger_students_updated_at
    BEFORE UPDATE ON public.students
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trigger_app_config_updated_at ON public.app_config;
CREATE TRIGGER trigger_app_config_updated_at
    BEFORE UPDATE ON public.app_config
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 5. ROW LEVEL SECURITY (RLS) & HAK AKSES API (ANON & AUTH)
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- Policy untuk Classes
DROP POLICY IF EXISTS "Anon Full Access Classes" ON public.classes;
CREATE POLICY "Anon Full Access Classes" ON public.classes FOR ALL TO anon USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Auth Full Access Classes" ON public.classes;
CREATE POLICY "Auth Full Access Classes" ON public.classes FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Policy untuk App Config
DROP POLICY IF EXISTS "Anon Full Access AppConfig" ON public.app_config;
CREATE POLICY "Anon Full Access AppConfig" ON public.app_config FOR ALL TO anon USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Auth Full Access AppConfig" ON public.app_config;
CREATE POLICY "Auth Full Access AppConfig" ON public.app_config FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Policy untuk Students (Siswa & Guru)
DROP POLICY IF EXISTS "Anon Full Access Students" ON public.students;
CREATE POLICY "Anon Full Access Students" ON public.students FOR ALL TO anon USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Auth Full Access Students" ON public.students;
CREATE POLICY "Auth Full Access Students" ON public.students FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ========================================================
-- 6. DATA AWAL (SEED DATA): KELAS & PENGATURAN
-- ========================================================
INSERT INTO public.classes (name)
VALUES ('VIII A'), ('VIII B')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.app_config (id, app_name, school_name, subject_name, teacher_name, academic_year, kkm, max_attendance, admin_password)
VALUES (1, 'NILAIKU', 'SMP ISLAM AL AZHAR 30 TASIKMALAYA', 'BAHASA INDONESIA', 'Dadi, S.Pd., Gr', '2026/2027', 75, 16, 'guru123')
ON CONFLICT (id) DO UPDATE SET
    app_name = EXCLUDED.app_name,
    school_name = EXCLUDED.school_name,
    subject_name = EXCLUDED.subject_name,
    teacher_name = EXCLUDED.teacher_name,
    academic_year = EXCLUDED.academic_year;

-- ========================================================
-- 7. DATA AWAL (SEED DATA): 52 SISWA KELAS VIII A & VIII B
-- ========================================================
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526101', 'Adinda Sabina Putri Cuhva', 'VIII A', 16, 88, 85, 90, 86, 92, 88, 90, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526102', 'Alisha Khusnaira', 'VIII A', 16, 92, 90, 95, 92, 94, 93, 94, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526103', 'Anaya Waheeda Prilia', 'VIII A', 15, 84, 82, 85, 80, 88, 84, 86, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526104', 'Bilqis Sharliz Queenzha', 'VIII A', 16, 90, 88, 92, 90, 95, 90, 92, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526105', 'Daffa Al Abrar Al Fansyah', 'VIII A', 14, 78, 75, 72, NULL, 76, 74, NULL, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526106', 'Janetta Aleyza Andiputri', 'VIII A', 16, 88, 90, 86, 92, 90, 89, 91, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526107', 'Kasyfi Syarifi Rosdiansyah', 'VIII A', 15, 82, 80, 85, 84, 86, 82, 85, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526108', 'Keenar Liyana', 'VIII A', 16, 94, 92, 96, 95, 98, 95, 96, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526109', 'M Revhan Akhtar Aditya', 'VIII A', 14, 76, 74, 80, 75, NULL, 78, NULL, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526110', 'M. Raffa Azzikra', 'VIII A', 15, 80, 82, 84, 80, 85, 82, 84, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526111', 'Mikalla Efrans Wiramapta', 'VIII A', 16, 86, 88, 85, 90, 88, 87, 89, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526112', 'Moch Bilal Muhaimin Pranata', 'VIII A', 13, 72, NULL, 74, 70, 75, 72, NULL, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526113', 'Moh Mandala Putra', 'VIII A', 15, 85, 84, 86, 88, 90, 86, 88, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526114', 'Muh Al Fatih Mikail Marindra', 'VIII A', 16, 90, 92, 88, 94, 92, 91, 93, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526115', 'Muhammad Aldrin Alghifari', 'VIII A', 15, 82, 85, 80, 86, 84, 83, 85, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526116', 'Nafis Ahmad A', 'VIII A', 15, 84, 82, 86, 85, 88, 85, 87, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526117', 'Nindya Kireina Ramadhani', 'VIII A', 16, 92, 90, 94, 95, 96, 93, 95, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526118', 'Nizar Zilmi Syahban', 'VIII A', 15, 80, 78, 82, 84, 82, 80, 83, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526119', 'Pradipta Driyarkara Qytara Puruhita Galur Suryana Putri', 'VIII A', 16, 95, 94, 96, 98, 97, 96, 97, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526120', 'Qhillan Tanisya Saquilla', 'VIII A', 16, 88, 86, 90, 92, 89, 89, 91, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526121', 'Qisya Batrisya Irdina', 'VIII A', 16, 91, 92, 90, 93, 95, 92, 94, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526122', 'Salma Khoerunnisa', 'VIII A', 16, 89, 91, 88, 92, 90, 90, 92, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526123', 'Syaima Nurul Aisyah', 'VIII A', 16, 93, 95, 92, 94, 96, 94, 95, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526124', 'Tazka Azfar Ramadhan', 'VIII A', 15, 84, 82, 85, 86, 88, 85, 87, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526125', 'Tiara Mega Nurliana', 'VIII A', 16, 90, 92, 91, 94, 93, 91, 93, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526126', 'Vidya Nur Ismaya Putri', 'VIII A', 16, 92, 94, 95, 96, 95, 93, 95, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526002', 'Ainzya Putri M', 'VIII B', 20, 81, 80, 80, 80, 85, 80, 0, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526004', 'Alfina Nadia Fauziah', 'VIII B', 16, 85, 88, 86, 84, 85, 85, 80, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526011', 'Aryan Rasyad Noor Iksan', 'VIII B', 15, 82, 80, 85, 84, 86, 83, 82, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526015', 'Chayra Ghaziya Zahran', 'VIII B', 16, 90, 92, 88, 90, 94, 91, 90, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526017', 'Devan Alvian Mubarok', 'VIII B', 15, 80, 82, 84, 85, 80, 82, 84, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526019', 'Fadlan Fazlurrahman', 'VIII B', 16, 86, 88, 85, 87, 89, 87, 88, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526020', 'Faisya Nida Rahmah', 'VIII B', 16, 88, 90, 92, 89, 91, 90, 92, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526021', 'Faiz Muhammad Faisal', 'VIII B', 15, 84, 82, 86, 85, 88, 85, 86, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526023', 'Farin Naura Zafarani', 'VIII B', 16, 91, 93, 90, 92, 94, 92, 93, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526026', 'Hannah Sabrina Maryam', 'VIII B', 16, 90, 89, 92, 91, 95, 91, 92, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526032', 'Keyra Navira Danate', 'VIII B', 15, 85, 84, 88, 86, 87, 86, 88, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526034', 'Lintang Ramadhan Sukmadiraja', 'VIII B', 15, 83, 85, 82, 86, 84, 84, 85, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526037', 'Maryam Ali', 'VIII B', 16, 92, 94, 91, 93, 95, 93, 94, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526040', 'Muhammad Irsyad Rifky Alkhairu', 'VIII B', 15, 82, 84, 80, 85, 83, 84, 85, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526049', 'Muhammad Kenzie Ammar Sudjana', 'VIII B', 14, 78, 75, 72, NULL, 76, 74, NULL, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526033', 'Muhammad Khairan Fasyza Jabar', 'VIII B', 16, 89, 91, 88, 90, 92, 90, 91, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526050', 'Muhammad Rizky Abdul Ba''its', 'VIII B', 15, 86, 85, 88, 87, 89, 87, 88, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526054', 'Naura Ayumi', 'VIII B', 16, 94, 93, 95, 96, 97, 95, 96, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526060', 'Qonita Hanifa', 'VIII B', 16, 91, 90, 93, 92, 94, 92, 93, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526063', 'Ray Jibran Elbany', 'VIII B', 15, 85, 86, 84, 88, 87, 86, 87, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526065', 'Rizqi Rijaldi', 'VIII B', 16, 88, 90, 87, 89, 91, 89, 90, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526067', 'Rizqia Nafiza Putri Eldiansyah', 'VIII B', 16, 93, 92, 95, 94, 96, 94, 95, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526070', 'Shayna Clarissa Abelia', 'VIII B', 16, 90, 92, 89, 91, 93, 91, 92, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526069', 'Syabil Azhfar Hidayat', 'VIII B', 15, 84, 85, 82, 86, 85, 85, 86, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526072', 'Syakira Az Zahra', 'VIII B', 16, 95, 94, 96, 97, 98, 96, 97, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
INSERT INTO public.students (nisn, name, class, attendance, task_1, task_2, task_3, task_4, task_5, asts, asaj, manual_final_score)
VALUES ('4330-2526075', 'Zaky Fajarul Anwar', 'VIII B', 15, 87, 88, 85, 89, 88, 88, 89, NULL)
ON CONFLICT (nisn) DO UPDATE SET
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
