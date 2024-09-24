# Base image
FROM node:18

WORKDIR /app

RUN npx create-next-app@latest . --use-npm && \
    npm install shadcn-ui && \
    npm install -D tailwindcss postcss autoprefixer && \
    npm install lucide-react
RUN npx tailwindcss init

EXPOSE 3000

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]