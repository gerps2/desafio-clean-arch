.PHONY: help build run migrate-up migrate-down migrate-create docker-up docker-down

ENV_FILE := cmd/ordersystem/.env

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the application
	go build -o bin/ordersystem ./cmd/ordersystem

run: ## Run the application
	go run ./cmd/ordersystem

docker-up: ## Start docker containers
	docker-compose up -d

docker-down: ## Stop docker containers
	docker-compose down

migrate-up: install-migrate check-env ## Run database migrations up
	$(eval DB_USER=$(shell grep DB_USER $(ENV_FILE) | cut -d= -f2))
	$(eval DB_PASSWORD=$(shell grep DB_PASSWORD $(ENV_FILE) | cut -d= -f2))
	$(eval DB_HOST=$(shell grep DB_HOST $(ENV_FILE) | cut -d= -f2))
	$(eval DB_PORT=$(shell grep DB_PORT $(ENV_FILE) | cut -d= -f2))
	$(eval DB_NAME=$(shell grep DB_NAME $(ENV_FILE) | cut -d= -f2))
	migrate -path=migrations -database="mysql://$(DB_USER):$(DB_PASSWORD)@tcp($(DB_HOST):$(DB_PORT))/$(DB_NAME)" -verbose up

migrate-down: install-migrate check-env ## Run database migrations down
	$(eval DB_USER=$(shell grep DB_USER $(ENV_FILE) | cut -d= -f2))
	$(eval DB_PASSWORD=$(shell grep DB_PASSWORD $(ENV_FILE) | cut -d= -f2))
	$(eval DB_HOST=$(shell grep DB_HOST $(ENV_FILE) | cut -d= -f2))
	$(eval DB_PORT=$(shell grep DB_PORT $(ENV_FILE) | cut -d= -f2))
	$(eval DB_NAME=$(shell grep DB_NAME $(ENV_FILE) | cut -d= -f2))
	migrate -path=migrations -database="mysql://$(DB_USER):$(DB_PASSWORD)@tcp($(DB_HOST):$(DB_PORT))/$(DB_NAME)" -verbose down

check-env: ## Check if .env file exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "\033[0;31mERRO: Arquivo $(ENV_FILE) não encontrado!\033[0m"; \
		echo "É necessário criar o arquivo .env em cmd/ordersystem com as configurações de conexão ao banco de dados."; \
		echo "Exemplo de conteúdo necessário:"; \
		echo "DB_DRIVER="; \
		echo "DB_HOST="; \
		echo "DB_PORT="; \
		echo "DB_USER="; \
		echo "DB_PASSWORD="; \
		echo "DB_NAME="; \
		exit 1; \
	fi

migrate-create: install-migrate ## Create a new migration file (usage: make migrate-create name=migration_name)
	migrate create -ext=sql -dir=migrations -seq $(name)

install-migrate: ## Install golang-migrate tool
	@which migrate > /dev/null || go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

deps: ## Download dependencies
	go mod download
	go mod tidy

test: ## Run tests
	go test ./...

wire: ## Generate wire dependencies
	cd cmd/ordersystem && wire

clean: ## Clean build artifacts
	rm -rf bin/
