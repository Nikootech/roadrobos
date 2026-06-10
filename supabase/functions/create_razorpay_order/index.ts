// @ts-nocheck
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. Handle CORS Preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. Read environment credentials
    const razorpayKeyId = Deno.env.get('RAZORPAY_KEY_ID')
    const razorpayKeySecret = Deno.env.get('RAZORPAY_KEY_SECRET')

    if (!razorpayKeyId || !razorpayKeySecret) {
      throw new Error('Razorpay credentials are not configured in environment variables.')
    }

    // 3. Parse input body
    const { amount, currency } = await req.json()
    if (!amount) {
      return new Response(JSON.stringify({ error: 'Missing amount parameter' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 4. Call Razorpay API to create an order
    // Auth header is Basic Auth (base64 of key_id:key_secret)
    const basicAuth = btoa(`${razorpayKeyId}:${razorpayKeySecret}`)
    
    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${basicAuth}`,
      },
      body: JSON.stringify({
        amount: Math.round(amount), // must be integer (in paise)
        currency: currency || 'INR',
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Razorpay Order creation failed: ${errorText}`)
    }

    const orderData = await response.json()

    // 5. Return the created order details (specifically order_id)
    return new Response(JSON.stringify({ order_id: orderData.id, ...orderData }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
