FROM golang:1.23-alpine AS builder

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

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh

# Install migrate tool and netcat
RUN apk add --no-cache curl netcat-openbsd && \
    curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz | tar xvz && \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate && \
    chmod +x /app/entrypoint.sh && \
    apk del curl

EXPOSE 8000 50051 8080

ENTRYPOINT ["/app/entrypoint.sh"]
