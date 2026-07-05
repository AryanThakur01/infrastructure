// Lambda Invocation Handler
import { Handler } from 'aws-lambda';
import { HttpStatusCode } from './constants';
import { IResponse } from './interfaces/response';
import { sendResponse } from './utils/response';
import { ApiError } from './utils/errors';

export const handler: Handler<unknown, IResponse> = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  try {
    return sendResponse({
      statusCode: HttpStatusCode.NOT_IMPLEMENTED,
      message: 'This Lambda function is not yet implemented.'
    });
  } catch (error) {
    if (error instanceof Error) {
      return sendResponse({
        statusCode: HttpStatusCode.INTERNAL_SERVER_ERROR,
        message: error.message
      });
    }
    if (error instanceof ApiError) {
      return sendResponse({
        statusCode: error.statusCode,
        message: error.message
      });
    }
    return sendResponse({
      statusCode: HttpStatusCode.INTERNAL_SERVER_ERROR,
      message: 'Unknown error'
    });
  }
};
