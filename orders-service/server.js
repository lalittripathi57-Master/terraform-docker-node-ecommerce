const express = require('express');
const app = express();
const PORT = process.env.PORT || 3003;
app.get('/', (req, res) => res.json({ service: 'orders', message: 'Orders Service Running' }));
app.get('/health', (req, res) => res.json({ status: 'UP', service: 'orders' }));
app.listen(PORT, '0.0.0.0', () => console.log(`Orders service running on port ${PORT}`));
