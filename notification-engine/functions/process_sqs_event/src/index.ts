import { handler } from './functions/process_sqs_event/handler';

(async () => {
  handler({} as any, {} as any, () => {});
})();
