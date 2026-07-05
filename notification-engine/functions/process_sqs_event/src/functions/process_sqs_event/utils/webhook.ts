import * as crypto from 'crypto';
import { ENV } from '../configs';

interface WebhookPayload {
  jobId: string;
  status: 'failed' | 'completed';
  message: string;
  finalUrl: string | null;
}

export async function sendWebhook(
  callbackUrl: string,
  payload: WebhookPayload
) {
  const payloadString = JSON.stringify(payload);

  // Compute HMAC-SHA256 signature
  const signature = crypto
    .createHmac('sha256', ENV.WEBHOOK_SECRET)
    .update(payloadString)
    .digest('hex');

  // Send POST request with signature header
  await fetch(callbackUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-signature': signature
    },
    body: payloadString
  });

  console.log('Webhook sent with payload:', payload);
}
