const express = require('express');
const http = require('http');
const app = express();
const PORT = process.env.PORT || 3000;

const services = {
  user: process.env.USER_SERVICE_URL || 'http://user-service:3001',
  products: process.env.PRODUCTS_SERVICE_URL || 'http://products-service:3002',
  orders: process.env.ORDERS_SERVICE_URL || 'http://orders-service:3003',
  cart: process.env.CART_SERVICE_URL || 'http://cart-service:3004'
};

function check(url) {
  return new Promise((resolve) => {
    const req = http.get(`${url}/health`, { timeout: 2000 }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => resolve({ ok: res.statusCode === 200, response: body }));
    });
    req.on('timeout', () => { req.destroy(); resolve({ ok: false, error: 'timeout' }); });
    req.on('error', err => resolve({ ok: false, error: err.message }));
  });
}

app.get('/', (req, res) => {
  res.send(`<!doctype html>
  <html><head><title>Node E-commerce</title>
  <style>body{font-family:Arial;max-width:800px;margin:60px auto;padding:0 20px}h1{font-size:40px}code{background:#eee;padding:3px 6px}</style></head>
  <body><h1>Frontend is Live</h1><p>Multi-Service Node.js E-commerce Application deployed with <b>Terraform + Docker + AWS EC2</b>.</p>
  <p>Backend services: user (3001), products (3002), orders (3003), cart (3004).</p>
  <p>Check internal service connectivity at <code>/api-status</code>.</p></body></html>`);
});

app.get('/api-status', async (req, res) => {
  const results = {};
  for (const [name, url] of Object.entries(services)) results[name] = await check(url);
  res.json(results);
});

app.get('/health', (req, res) => res.json({ status: 'UP', service: 'frontend' }));
app.listen(PORT, '0.0.0.0', () => console.log(`Frontend running on port ${PORT}`));
