# Use official Node.js LTS image
FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
