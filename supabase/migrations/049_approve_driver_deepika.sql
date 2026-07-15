-- Migration: 049_approve_driver_deepika.sql
-- Description: Instantly approve KYC documents and driver profile status for deepikakannadasan1995@gmail.com (ID: b9009fbc-bbc6-4657-98f1-1d7fd243de1b) to verify the driver dashboard flow.

-- 1. Temporarily disable specific user triggers (since auth.uid() is null in dashboard SQL Editor)
ALTER TABLE public.profiles DISABLE TRIGGER tr_prevent_sensitive_profile_modification;

UPDATE public.profiles
SET 
  role = 'driver',
  kyc_status = 'approved',
  is_approved = true
WHERE id = 'b9009fbc-bbc6-4657-98f1-1d7fd243de1b';

ALTER TABLE public.profiles ENABLE TRIGGER tr_prevent_sensitive_profile_modification;

-- 2. Insert/update all KYC documents to 'approved' status
INSERT INTO public.partner_kyc (user_id, document_type, document_url, status)
VALUES 
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'aadhar_front', 'https://example.com/aadhar_front.jpg', 'approved'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'aadhar_back', 'https://example.com/aadhar_back.jpg', 'approved'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'driving_license_front', 'https://example.com/dl_front.jpg', 'approved'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'driving_license_back', 'https://example.com/dl_back.jpg', 'approved'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'vehicle_rc', 'https://example.com/vehicle_rc.jpg', 'approved'),
  ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 'selfie', 'https://example.com/selfie.jpg', 'approved')
ON CONFLICT (user_id, document_type) 
DO UPDATE SET 
  status = 'approved',
  updated_at = NOW();

-- 3. Insert or update the drivers table row for this driver
INSERT INTO public.drivers (id, name, phone, vehicle_model, chassis_number, license_number, approval_status)
VALUES (
  'b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 
  'Deepika Kannadasan', 
  '+919876543210', 
  'Activa 6G', 
  'CHASSIS123456789', 
  'DL1234567890123', 
  'approved'
)
ON CONFLICT (id) 
DO UPDATE SET 
  approval_status = 'approved',
  name = EXCLUDED.name,
  phone = EXCLUDED.phone;

-- 4. Insert or update the wallet for this driver to allow testing withdrawal
INSERT INTO public.wallets (id, balance)
VALUES ('b9009fbc-bbc6-4657-98f1-1d7fd243de1b', 15000.00)
ON CONFLICT (id) 
DO UPDATE SET balance = 15000.00;

