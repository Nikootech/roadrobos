import { serve } from "http/server.ts"
import { createClient } from "@supabase/supabase-js"
import { JWT } from "google-auth-library"

const getFirebaseAccessToken = async () => {
  const serviceAccountStr = Deno.env.get('FCM_SERVICE_ACCOUNT_KEY');
  if (!serviceAccountStr) throw new Error("FCM_SERVICE_ACCOUNT_KEY missing");
  const serviceAccount = JSON.parse(serviceAccountStr);

  const client = new JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });
  
  const token = await client.getAccessToken();
  return { token: token.token, projectId: serviceAccount.project_id };
};

const sendFcmMessage = async (fcmToken: string, title: string, body: string, data: Record<string, unknown>) => {
  const auth = await getFirebaseAccessToken();
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${auth.projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${auth.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: { title, body },
          data,
        }
      })
    }
  );
  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`FCM send failed: ${response.status} ${errorBody}`);
  }
  return response.json();
};

serve(async (req: Request) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const payload = await req.json();
    const newRecord = payload.record;
    
    // In approvals, maker_id is the user who requested KYC
    if (!newRecord || !newRecord.maker_id) {
      return new Response(JSON.stringify({ error: "Missing maker_id" }), { status: 400 });
    }

    if (newRecord.type !== 'partner_kyc' || newRecord.status !== 'approved') {
      return new Response(JSON.stringify({ success: true, message: "Ignored event" }), { status: 200 });
    }

    // Get FCM Token
    const { data: profile, error: profileErr } = await supabaseClient
      .from('profiles')
      .select('fcm_token')
      .eq('id', newRecord.maker_id)
      .single();

    if (profileErr || !profile?.fcm_token) {
      return new Response(JSON.stringify({ error: "No FCM token for user" }), { status: 404 });
    }

    const title = "KYC Approved!";
    const body = "Your KYC has been verified! You can now start accepting jobs.";
    const msgData = { type: 'kyc_approved', id: newRecord.id };

    await sendFcmMessage(profile.fcm_token, title, body, msgData);

    // Log success
    await supabaseClient.from('notification_log').insert({
      user_id: newRecord.maker_id,
      type: 'kyc_approved',
      title,
      body,
      status: 'sent'
    });

    return new Response(JSON.stringify({ success: true }), { headers: { "Content-Type": "application/json" } });
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : String(err);
    console.error("Error:", errorMsg);
    return new Response(JSON.stringify({ error: errorMsg }), { status: 500 });
  }
});
