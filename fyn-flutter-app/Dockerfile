# Build stage
# syntax=docker/dockerfile:1.6

FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency graph first to maximize Docker layer caching
COPY pubspec.yaml pubspec.lock ./

# Pre-fetch packages (lockfile enforced) and cache artifacts
RUN --mount=type=cache,target=/root/.pub-cache \
    flutter pub get --suppress-analytics

# Copy the rest of the source code
COPY . .

# Create .env file from build arg (if provided)
ARG BASE_URL=http://localhost:8080
RUN echo "BASE_URL=$BASE_URL" > .env

# Build Flutter web app (cache Gradle/artifacts between builds)
RUN --mount=type=cache,target=/root/.pub-cache \
    --mount=type=cache,target=/root/.gradle \
    flutter build web --release

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

