FROM node:26-alpine as builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install || npm ci --omit=dev || echo "Using npm install fallback"

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
