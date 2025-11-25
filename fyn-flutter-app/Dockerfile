# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec file
COPY pubspec.yaml ./

# Get dependencies (this will create pubspec.lock if it doesn't exist)
RUN flutter pub get

# Copy source code
COPY . .

# Create .env file from build arg (if provided)
ARG BASE_URL=http://localhost:8080
RUN echo "BASE_URL=$BASE_URL" > .env

# Build Flutter web app
RUN flutter build web --release

# Production stage
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

