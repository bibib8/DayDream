-- Migration 002: Add delete_user function to allow users to delete their account
-- Function public.delete_user() runs as SECURITY DEFINER to delete auth.users record.
-- All child tables (profiles, diaries, entries, mood_logs) cascade on delete.

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
