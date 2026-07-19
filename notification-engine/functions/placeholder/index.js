// Placeholder handler. Terraform deploys this once so the Lambda + Function URL
// exist. Your NestJS project overwrites this code on its own deploy.
exports.handler = async () => ({
  statusCode: 200,
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({ message: 'placeholder — deploy the NestJS app to replace this' }),
});
