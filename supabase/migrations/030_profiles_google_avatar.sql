-- ========================================================
-- Description: Update handle_new_user() trigger function to
--              fetch and insert the profile picture from Google/OAuth
--              metadata (avatar_url, picture, or photo_url).
-- ========================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, profile_pic)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'New User'),
    new.email,
    COALESCE(
      new.raw_user_meta_data->>'avatar_url',
      new.raw_user_meta_data->>'picture',
      new.raw_user_meta_data->>'photo_url'
    )
  );
  
  INSERT INTO public.wallets (id, balance)
  VALUES (new.id, 0.00);
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
