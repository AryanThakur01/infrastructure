import { IResponse } from '../interfaces/response';

export const sendResponse = ({
  statusCode,
  data,
  message
}: IResponse): IResponse => {
  return { statusCode, data, message };
};
