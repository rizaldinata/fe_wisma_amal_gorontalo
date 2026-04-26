# Stage 1: Build stage
FROM ghcr.io/cirruslabs/flutter:stable as build

WORKDIR /app
COPY . .

# Run flutter build web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Production stage
FROM nginx:alpine

# Copy the built files from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
