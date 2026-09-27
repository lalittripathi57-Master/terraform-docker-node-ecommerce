FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY server.js ./
EXPOSE 3004
CMD ["npm", "start"]
