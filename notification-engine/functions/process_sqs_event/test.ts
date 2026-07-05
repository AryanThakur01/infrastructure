import { handler } from './src/functions/process_sqs_event/handler';

(async () => {
  console.log('--- PROCESS SQS EVENT ---');
  const result = await handler(
    {
      webhookUrl: 'https://webhook.site/a1876fde-46ba-4314-99ed-644fef8536e4',
      data: { message: 'Hello, World!' }
    } as any,
    {} as any,
    () => {}
  );
  console.log(JSON.stringify(result, null, 2));
})();
