const express = require('express');
const app = express();
const PORT = process.env.PORT || 3004;
app.get('/', (req, res) => res.json({ service: 'cart', message: 'Cart Service Running' }));
app.get('/health', (req, res) => res.json({ status: 'UP', service: 'cart' }));
app.listen(PORT, '0.0.0.0', () => console.log(`Cart service running on port ${PORT}`));
