#!/bin/sh

echo "Waiting for MySQL to be ready..."
while ! nc -z ${DB_HOST} ${DB_PORT}; do
  echo "Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."
  sleep 2
done
echo "MySQL is ready!"

echo "Running migrations..."
migrate -path=migrations -database="mysql://${DB_USER}:${DB_PASSWORD}@tcp(${DB_HOST}:${DB_PORT})/${DB_NAME}" -verbose up

if [ $? -eq 0 ]; then
  echo "Migrations completed successfully!"
else
  echo "Migration failed!"
  exit 1
fi

echo "Starting application..."
./ordersystem
