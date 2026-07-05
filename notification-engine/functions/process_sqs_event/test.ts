import { handler } from './src/functions/process_sqs_event/handler';

(async () => {
  console.log('--- PROCESS SQS EVENT ---');
  const result = await handler(
    {},
    {} as any,
    () => {}
  );
  console.log(JSON.stringify(result, null, 2));
})();
