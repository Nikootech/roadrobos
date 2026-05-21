import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const webhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET")!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function verifySignature(payload: string, signature: string, secret: string): Promise<boolean> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  
  const signatureBuffer = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(payload)
  );
  
  const signatureArray = Array.from(new Uint8Array(signatureBuffer));
  const expectedSignatureHex = signatureArray.map(b => b.toString(16).padStart(2, '0')).join('');

  return signature === expectedSignatureHex;
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const signature = req.headers.get('x-razorpay-signature');
  if (!signature) {
    return new Response('Missing signature', { status: 400 });
  }

  const payloadStr = await req.text();
  
  try {
    const isValid = await verifySignature(payloadStr, signature, webhookSecret);
    if (!isValid) {
      console.error('Invalid signature');
      return new Response('Invalid signature', { status: 400 });
    }

    const event = JSON.parse(payloadStr);

    if (event.event === 'payment.captured') {
      const payment = event.payload.payment.entity;
      
      const paymentId = payment.id;
      // We expect booking_id and user_id to be passed in notes
      const bookingId = payment.notes?.booking_id;
      const userId = payment.notes?.user_id;
      const amount = payment.amount / 100; // Convert from paise

      if (bookingId && userId) {
        const { error } = await supabase.rpc('process_payment', {
          payment_id: paymentId,
          booking_id: bookingId,
          amount: amount,
          user_id: userId
        });

        if (error) {
          console.error('RPC Error:', error);
          return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: { 'Content-Type': 'application/json' } });
        }
      } else {
        console.log('Skipping RPC: missing booking_id or user_id in notes');
      }
    }

    return new Response('OK', { status: 200 });
  } catch (err) {
    console.error('Webhook error:', err);
    return new Response('Internal error', { status: 500 });
  }
});
