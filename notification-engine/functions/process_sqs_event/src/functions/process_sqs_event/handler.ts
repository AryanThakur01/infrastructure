import { SQSBatchResponse, SQSHandler } from 'aws-lambda';
import { eventSchema } from './schemas';
import { sendResponse } from './utils/response';
import { IdempotentExecutor } from './services/idempotent-executor';

const idempotentExecutorService = new IdempotentExecutor();
export const handler: SQSHandler = async (event) => {
  const statuses = await Promise.allSettled(
    event.Records.map(async (ev) => {
      const bodyRaw =
        typeof ev.body === 'string' ? JSON.parse(ev.body) : ev.body;
      const body = eventSchema.parse(bodyRaw);

      if (body.data.handleType === 'error')
        throw new Error('Simulated error for testing purposes');

      // Send the webhook request
      console.log(
        `Sending webhook request to ${body.webhookUrl} with data:`,
        body.data
      );
      const executeFetch = async () => {
        const res = await fetch(body.webhookUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body.data)
        });
        if (!res.ok) {
          throw new Error(
            `Failed to send webhook request. Status: ${res.status}, StatusText: ${res.statusText}`
          );
        }
      };

      await idempotentExecutorService.executeAll({
        messageId: ev.messageId,
        fns: [executeFetch]
      });

      return sendResponse({ batchItemFailures: [] });
    })
  );

  const batchedResponse: SQSBatchResponse = { batchItemFailures: [] };
  statuses.forEach((status, index) => {
    if (status.status === 'rejected') {
      batchedResponse.batchItemFailures.push({
        itemIdentifier: event.Records[index].messageId
      });
    }
  });

  return sendResponse(batchedResponse);
};
