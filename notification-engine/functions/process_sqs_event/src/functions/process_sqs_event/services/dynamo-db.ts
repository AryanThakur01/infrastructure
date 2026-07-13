import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand
} from '@aws-sdk/lib-dynamodb';

export enum Status {
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED'
}
interface IItem {
  id: string;
  sk: string;
  status: Status;
  executionError?: string | null;
}

export class DynamoDBService {
  private docClient: DynamoDBDocumentClient;
  private tableName: string;

  constructor(region: string, tableName: string) {
    const baseClient = new DynamoDBClient({ region });
    this.docClient = DynamoDBDocumentClient.from(baseClient);
    this.tableName = tableName;
  }

  async putItem(item: IItem): Promise<void> {
    const command = new PutCommand({
      TableName: this.tableName,
      Item: item
    });

    try {
      await this.docClient.send(command);
      console.log('Item written successfully');
    } catch (error) {
      console.error('Error writing item:', error);
      throw error;
    }
  }

  async getItem(key: Partial<IItem>): Promise<IItem | undefined> {
    const command = new GetCommand({ TableName: this.tableName, Key: key });

    try {
      const { Item } = await this.docClient.send(command);
      return Item as IItem | undefined;
    } catch (error) {
      console.error('Error getting item:', error);
      throw error;
    }
  }
}
