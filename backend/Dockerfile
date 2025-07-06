FROM node:18-alpine
WORKDIR /app
COPY package.json ./
COPY package-lock.json ./
RUN npm install --production
COPY . ./
ENV PORT=3001
EXPOSE 3001
CMD ["node", "app.js"] # Assuming app.js is your entry file