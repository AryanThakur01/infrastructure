import { SQSBatchResponse, SQSHandler } from 'aws-lambda';
import { eventSchema } from './schemas';
import { sendResponse } from './utils/response';

export const handler: SQSHandler = async (event) => {
  const statuses = await Promise.allSettled(
    event.Records.map(async (ev) => {
      const bodyRaw =
        typeof ev.body === 'string' ? JSON.parse(ev.body) : ev.body;
      const body = eventSchema.parse(bodyRaw);

      // Send the webhook request
      await fetch(body.webhookUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body.data)
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
