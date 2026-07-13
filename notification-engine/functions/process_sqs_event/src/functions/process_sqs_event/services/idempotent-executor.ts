import { DynamoDBService, Status } from './dynamo-db';

// Define the interface for the input to the IdempotentExecutor
interface IIdempotentExecutor {
  messageId: string;
  fns: TInputFunction;
}
type TInputFunction = (() => Promise<void>)[];

// Create an instance of DynamoDBService with the desired AWS region
const dynamoDbService = new DynamoDBService(
  'ap-south-1',
  'notification-engine'
);

// Class to execute functions idempotently based on messageId and functionName
export class IdempotentExecutor {
  private async shouldExecuteFunction(
    messageId: string,
    functionName: string
  ): Promise<boolean> {
    const existingItem = await dynamoDbService.getItem({
      id: messageId,
      sk: functionName
    });
    if (!existingItem) return true;
    if (existingItem.status === Status.COMPLETED) return false;
    if (existingItem.status === Status.IN_PROGRESS) return false;
    if (existingItem.status === Status.FAILED) return true;
    return true;
  }

  private async executeFunction(
    messageId: string,
    fn: () => Promise<void>
  ): Promise<void> {
    let executionError: string | null = null;
    const functionName = fn.name;
    console.log(`Executing fn(${functionName}), messageId(${messageId})`);

    const shouldExecute = await this.shouldExecuteFunction(
      messageId,
      functionName
    );

    if (!shouldExecute) {
      console.log(`Skipped fn(${functionName}), messageId(${messageId})`);
      return;
    }

    try {
      const res = await fn();
      await dynamoDbService.putItem({
        id: messageId,
        sk: functionName,
        status: Status.COMPLETED,
        executionError
      });
      return res;
    } catch (error) {
      if (error instanceof Error) executionError = error.message;
      else executionError = 'Unknown error occurred';

      await dynamoDbService.putItem({
        id: messageId,
        sk: functionName,
        status: Status.FAILED,
        executionError
      });
      throw error;
    }
  }

  public async executeAll(input: IIdempotentExecutor): Promise<void> {
    const { messageId, fns } = input;

    const promises = fns.map((fn) => this.executeFunction(messageId, fn));
    const settledFns = await Promise.allSettled(promises);

    if (settledFns.some((result) => result.status === 'rejected')) {
      const errors = settledFns
        .filter((result) => result.status === 'rejected')
        .map((result) => (result as PromiseRejectedResult).reason);
      throw new Error(
        `One or more functions failed to execute. Job needs to be retried for them. Errors: ${errors.join(', ')}`
      );
    }
  }
}
