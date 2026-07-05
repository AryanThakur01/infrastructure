import { SQSBatchResponse } from 'aws-lambda';

export const sendResponse = ({
  batchItemFailures
}: SQSBatchResponse): SQSBatchResponse => {
  return { batchItemFailures: batchItemFailures || [] };
};
