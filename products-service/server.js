const express = require('express');
const app = express();
const PORT = process.env.PORT || 3002;
app.get('/', (req, res) => res.json({ service: 'products', message: 'Products Service Running' }));
app.get('/health', (req, res) => res.json({ status: 'UP', service: 'products' }));
app.listen(PORT, '0.0.0.0', () => console.log(`Products service running on port ${PORT}`));
