function handler(event) {
  var req = event.request;
  var uri = req.uri;
  if (!uri.includes('.')) {
    req.uri = '/index.html';
  }
  return req;
}
