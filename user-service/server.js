const express = require('express');
const app = express();
const PORT = process.env.PORT || 3001;
app.get('/', (req, res) => res.json({ service: 'user', message: 'User Service Running' }));
app.get('/health', (req, res) => res.json({ status: 'UP', service: 'user' }));
app.listen(PORT, '0.0.0.0', () => console.log(`User service running on port ${PORT}`));
