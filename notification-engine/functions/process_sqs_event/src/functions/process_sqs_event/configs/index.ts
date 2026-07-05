const getEnv = () => {
  if (!process.env.WEBHOOK_SECRET)
    throw new Error('WEBHOOK_SECRET is not defined in environment variables');
  if (!process.env.AWS_REGION)
    throw new Error('AWS_REGION is not defined in environment variables');
  if (!process.env.GEMINI_API_KEY)
    throw new Error('GEMINI_API_KEY is not defined in environment variables');
  if (!process.env.S3_BUCKET_NAME)
    throw new Error('S3_BUCKET_NAME is not defined in environment variables');
  if (!process.env.S3_BUCKET_REGION)
    throw new Error('S3_BUCKET_REGION is not defined in environment variables');
  if (!process.env.DISCORD_WEBHOOK_URL)
    throw new Error(
      'DISCORD_WEBHOOK_URL is not defined in environment variables'
    );

  return {
    WEBHOOK_SECRET: process.env.WEBHOOK_SECRET,
    AWS_REGION: process.env.AWS_REGION,
    GEMINI_API_KEY: process.env.GEMINI_API_KEY,
    S3_BUCKET_NAME: process.env.S3_BUCKET_NAME,
    S3_BUCKET_REGION: process.env.S3_BUCKET_REGION,
    DISCORD_WEBHOOK_URL: process.env.DISCORD_WEBHOOK_URL
  };
};

export const ENV = getEnv();
