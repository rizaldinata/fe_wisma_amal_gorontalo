FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy the app files to the container
COPY . .

# Get App Dependencies
RUN flutter pub get

# Build the app for the web with the dynamic BASE_URL
# The build arg will be passed from docker-compose or CI
ARG BASE_URL=https://api.wismaamal.allvvnt.my.id
RUN flutter build web --dart-define=BASE_URL=$BASE_URL --release

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the build output to replace the default nginx contents
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
