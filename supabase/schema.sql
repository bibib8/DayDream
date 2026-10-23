-- ==============================================================================
-- DAYDREAM DIGITAL DIARY - SUPABASE DATABASE SCHEMA
-- ==============================================================================
-- This script sets up all tables, indexes, Row Level Security (RLS) policies,
-- automatic triggers, and Storage Bucket for the Daydream app.
-- 
-- HOW TO USE:
-- 1. Open your Supabase Dashboard: https://supabase.com/dashboard
-- 2. Select your project: hxobywsfyqmyaltvmypk
-- 3. In the left navigation, click "SQL Editor"
-- 4. Click "+ New query", paste this entire script, and click "Run" (Ctrl+Enter)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 2. TABLES
-- ==============================================================================

-- 2.1 PROFILES TABLE (Linked directly to Supabase Auth users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    pen_name TEXT NOT NULL DEFAULT 'Sweet Dreamer',
    avatar_url TEXT DEFAULT '',
    streak_days INTEGER NOT NULL DEFAULT 1,
    diaries_count INTEGER NOT NULL DEFAULT 1,
    pages_count INTEGER NOT NULL DEFAULT 0,
    moods_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2.2 DIARIES TABLE (Diary volumes / journals on the Bookshelf)
CREATE TABLE IF NOT EXISTS public.diaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Parisian Film Diaries',
    description TEXT NOT NULL DEFAULT 'Analog snapshots & quiet reflections',
    cover_color TEXT NOT NULL DEFAULT '#E5F1FC',
    cover_theme TEXT NOT NULL DEFAULT 'classic',
    entries_count INTEGER NOT NULL DEFAULT 0,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2.3 ENTRIES TABLE (Pages written inside a diary)
CREATE TABLE IF NOT EXISTS public.entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    diary_id UUID NOT NULL REFERENCES public.diaries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Untitled Reverie',
    content TEXT NOT NULL DEFAULT '',
    entry_date TEXT NOT NULL,          -- e.g. "October 12, 2026"
    entry_time TEXT NOT NULL,          -- e.g. "10:30 AM"
    weather TEXT NOT NULL DEFAULT 'Crisp Blue Sky 🌤️',
    soundtrack TEXT NOT NULL DEFAULT 'Modjo – Lady 💿',
    paper_style TEXT NOT NULL DEFAULT 'paper-plain',   -- 'paper-plain', 'paper-grid', 'paper-lined', 'paper-dotted'
    font_family TEXT NOT NULL DEFAULT 'serif',         -- 'serif', 'editorial', 'handwriting', 'sans'
    mood_key TEXT NOT NULL DEFAULT 'happy',            -- 'happy', 'calm', 'productive', 'tired', 'stressed', 'down'
    mood_label TEXT NOT NULL DEFAULT 'Happy',
    mood_icon TEXT NOT NULL DEFAULT '😊',
    stickers JSONB NOT NULL DEFAULT '[]'::jsonb,       -- Array of sticker objects with x, y coordinates
    image_urls JSONB NOT NULL DEFAULT '[]'::jsonb,     -- Array of uploaded image URL strings
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2.4 MOOD_LOGS TABLE (Daily mood calendar records)
CREATE TABLE IF NOT EXISTS public.mood_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,                            -- e.g. '2026-10-12'
    day INTEGER NOT NULL,                              -- 1 to 31
    mood_key TEXT NOT NULL,                            -- 'happy', 'calm', 'productive', 'tired', 'stressed', 'down'
    note TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT unique_user_log_date UNIQUE (user_id, log_date)
);

-- ==============================================================================
-- 3. INDEXES FOR HIGH-PERFORMANCE QUERIES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_diaries_user_id ON public.diaries(user_id);
CREATE INDEX IF NOT EXISTS idx_entries_diary_id ON public.entries(diary_id);
CREATE INDEX IF NOT EXISTS idx_entries_user_id ON public.entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_logs_user_date ON public.mood_logs(user_id, log_date);

-- ==============================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- Ensures 100% data privacy: Each user only ever accesses their own data
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_logs ENABLE ROW LEVEL SECURITY;

-- 4.1 PROFILES POLICIES
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- 4.2 DIARIES POLICIES
DROP POLICY IF EXISTS "Users can view their own diaries" ON public.diaries;
CREATE POLICY "Users can view their own diaries"
    ON public.diaries FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own diaries" ON public.diaries;
CREATE POLICY "Users can create their own diaries"
    ON public.diaries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own diaries" ON public.diaries;
CREATE POLICY "Users can update their own diaries"
    ON public.diaries FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own diaries" ON public.diaries;
CREATE POLICY "Users can delete their own diaries"
    ON public.diaries FOR DELETE
    USING (auth.uid() = user_id);

-- 4.3 ENTRIES POLICIES
DROP POLICY IF EXISTS "Users can view their own entries" ON public.entries;
CREATE POLICY "Users can view their own entries"
    ON public.entries FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own entries" ON public.entries;
CREATE POLICY "Users can create their own entries"
    ON public.entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own entries" ON public.entries;
CREATE POLICY "Users can update their own entries"
    ON public.entries FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own entries" ON public.entries;
CREATE POLICY "Users can delete their own entries"
    ON public.entries FOR DELETE
    USING (auth.uid() = user_id);

-- 4.4 MOOD_LOGS POLICIES
DROP POLICY IF EXISTS "Users can view their own mood logs" ON public.mood_logs;
CREATE POLICY "Users can view their own mood logs"
    ON public.mood_logs FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own mood logs" ON public.mood_logs;
CREATE POLICY "Users can insert their own mood logs"
    ON public.mood_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own mood logs" ON public.mood_logs;
CREATE POLICY "Users can update their own mood logs"
    ON public.mood_logs FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own mood logs" ON public.mood_logs;
CREATE POLICY "Users can delete their own mood logs"
    ON public.mood_logs FOR DELETE
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 5. STORAGE BUCKET FOR DIARY MEDIA & PHOTOS
-- Configures maximum 2 MB per file and allows JPG, PNG, WebP
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'diary-media',
    'diary-media',
    true,
    2097152, -- 2 Megabytes limit (2 * 1024 * 1024)
    ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 2097152,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp']::text[];

-- Storage Object Access Policies
DROP POLICY IF EXISTS "Public can view diary images" ON storage.objects;
CREATE POLICY "Public can view diary images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'diary-media');

DROP POLICY IF EXISTS "Authenticated users can upload diary images" ON storage.objects;
CREATE POLICY "Authenticated users can upload diary images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'diary-media' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can update their own diary images" ON storage.objects;
CREATE POLICY "Users can update their own diary images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'diary-media' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

DROP POLICY IF EXISTS "Users can delete their own diary images" ON storage.objects;
CREATE POLICY "Users can delete their own diary images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'diary-media' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ==============================================================================
-- 6. AUTOMATIC TRIGGERS & FUNCTIONS
-- ==============================================================================

-- 6.1 Function to automatically create a Profile and Starter Diary on User Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    new_pen_name TEXT;
    starter_diary_id UUID;
BEGIN
    new_pen_name := COALESCE(NEW.raw_user_meta_data->>'pen_name', split_part(NEW.email, '@', 1), 'Sweet Dreamer');

    -- Insert Profile (pages_count = 0, moods_count = 0, diaries_count = 1)
    INSERT INTO public.profiles (id, email, pen_name, streak_days, diaries_count, pages_count, moods_count)
    VALUES (NEW.id, NEW.email, new_pen_name, 1, 1, 0, 0)
    ON CONFLICT (id) DO NOTHING;

    -- Create Starter Diary "My First Diary" for the new user (0 entries)
    INSERT INTO public.diaries (user_id, title, description, cover_color, cover_theme, entries_count, is_default)
    VALUES (
        NEW.id,
        'My First Diary',
        'A cozy space for thoughts, dreams, and quiet moments.',
        '#E5F1FC',
        'classic',
        0,
        true
    )
    RETURNING id INTO starter_diary_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger attached to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6.2 Trigger to maintain entries_count in diaries table
CREATE OR REPLACE FUNCTION public.handle_diary_entries_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.diaries SET entries_count = entries_count + 1 WHERE id = NEW.diary_id;
        UPDATE public.profiles SET pages_count = pages_count + 1 WHERE id = NEW.user_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.diaries SET entries_count = GREATEST(0, entries_count - 1) WHERE id = OLD.diary_id;
        UPDATE public.profiles SET pages_count = GREATEST(0, pages_count - 1) WHERE id = OLD.user_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_entry_count_changed ON public.entries;
CREATE TRIGGER on_entry_count_changed
    AFTER INSERT OR DELETE ON public.entries
    FOR EACH ROW EXECUTE FUNCTION public.handle_diary_entries_count();

-- 6.3 Function to safely delete the authenticated user's account and cascade all data
CREATE OR REPLACE FUNCTION public.delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

REVOKE EXECUTE ON FUNCTION public.delete_user() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.delete_user() TO authenticated;

-- ==============================================================================
-- DONE!
-- Your Supabase database is now fully configured with tables, RLS security,
-- storage bucket for 2MB images, automated signup triggers, and account deletion.
-- ==============================================================================

