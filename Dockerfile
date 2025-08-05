FROM golang:1.20-alpine AS builder

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o ordersystem ./cmd/ordersystem

# Create a minimal image
FROM alpine:3.17

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/ordersystem .
COPY --from=builder /app/migrations ./migrations

# Install migrate tool
RUN apk add --no-cache curl && \
    curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz | tar xvz && \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate && \
    apk del curl

# Create entrypoint script
RUN echo '#!/bin/sh\n\
echo "Waiting for MySQL to start..."\n\
sleep 10\n\
echo "Running migrations..."\n\
migrate -path=migrations -database="mysql://${DB_USER}:${DB_PASSWORD}@tcp(${DB_HOST}:${DB_PORT})/${DB_NAME}" -verbose up\n\
echo "Starting application..."\n\
./ordersystem\n' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

EXPOSE 8000 50051 8080

ENTRYPOINT ["/app/entrypoint.sh"]
