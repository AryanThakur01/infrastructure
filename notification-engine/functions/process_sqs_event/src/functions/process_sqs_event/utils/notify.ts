import { ENV } from '../configs';

export const sendDiscordMessage = async (
  message: string | string[]
): Promise<void> => {
  try {
    if (typeof message === 'object' && Array.isArray(message))
      message = `${message.map((line) => line.trim()).join('\n')}`;

    const webhookUrl = ENV.DISCORD_WEBHOOK_URL;

    if (!webhookUrl) {
      console.warn('[Discord] Webhook URL is not defined');
      return;
    }

    if (!message || !message.trim()) {
      console.warn('[Discord] Empty message skipped');
      return;
    }

    // await axios.post(webhookUrl, { content: `[${ env }]\n\`\`\`${ message.slice(0, 1500) }\`\`\`` });
    await fetch(webhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        content: `[MANDOS]\n\`\`\`${message.slice(0, 1500)}\`\`\``
      })
    });
  } catch (error) {
    console.error('[Discord] Failed to send message:', error);
  }
};
