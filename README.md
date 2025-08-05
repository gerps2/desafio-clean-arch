# Sistema de Pedidos

Uma implementação de Clean Architecture para um sistema de gerenciamento de pedidos com interfaces REST API, gRPC e GraphQL.

## Funcionalidades

- Criar e listar pedidos
- Múltiplas interfaces:
  - REST API (porta 8000)
  - gRPC (porta 50051)
  - GraphQL (porta 8080)
- Arquitetura orientada a eventos com RabbitMQ
- Implementação de Clean Architecture

## Stack Tecnológica

- Go
- MySQL
- RabbitMQ
- Chi Router (REST)
- gRPC
- GraphQL
- Wire (Injeção de Dependência)
- golang-migrate (Migrações de Banco de Dados)

## Configuração

### Pré-requisitos

- Go 1.19+
- Docker e Docker Compose
- golang-migrate (opcional para desenvolvimento local)

### Instalação

1. Clone o repositório:

```bash
git clone <repository-url>
cd desafio-clean-arch
```

2. Verifique se o arquivo de variáveis de ambiente existe:

```bash
# O arquivo .env deve estar em cmd/ordersystem/ com as configurações necessárias
# Exemplo de conteúdo:
# DB_DRIVER=mysql
# DB_HOST=localhost
# DB_PORT=3306
# DB_USER=root
# DB_PASSWORD=root
# DB_NAME=orders
# WEB_SERVER_PORT=:8000
# GRPC_SERVER_PORT=50051
# GRAPHQL_SERVER_PORT=8080
```

3. Inicie a infraestrutura (MySQL e RabbitMQ):

```bash
make docker-up
```

4. Execute as migrações do banco de dados:

```bash
make migrate-up
```

5. Compile e execute a aplicação:

```bash
make build
make run
```

### Usando Docker Compose

Para executar toda a stack da aplicação com Docker Compose:

```bash
docker-compose up -d
```

Isso iniciará:
- Banco de dados MySQL
- Message broker RabbitMQ
- Aplicação do Sistema de Pedidos com todas as interfaces

## Uso da API

Exemplos de requisições da API estão disponíveis no arquivo `api.http`. Você pode usar ferramentas como REST Client para VS Code ou Postman para executar essas requisições.

### REST API

- Criar Pedido: `POST http://localhost:8000/order`
- Listar Pedidos: `GET http://localhost:8000/order`

### GraphQL

- Endpoint: `http://localhost:8080/query`
- Mutation para Criar Pedido:
  ```graphql
  mutation {
    createOrder(input: {price: 100.0, tax: 10.0}) {
      id
      price
      tax
      final_price
    }
  }
  ```
- Query para Listar Pedidos:
  ```graphql
  query {
    orders {
      id
      price
      tax
      final_price
    }
  }
  ```

### gRPC

Usando grpcurl:

```bash
# Criar Pedido
grpcurl -d '{"price": 100.0, "tax": 10.0}' -plaintext localhost:50051 pb.OrderService/CreateOrder

# Listar Pedidos
grpcurl -plaintext localhost:50051 pb.OrderService/ListOrders
```

## Desenvolvimento

### Comandos do Makefile

- `make help` - Mostrar comandos disponíveis
- `make build` - Compilar a aplicação
- `make run` - Executar a aplicação
- `make docker-up` - Iniciar containers Docker
- `make docker-down` - Parar containers Docker
- `make migrate-up` - Executar migrações do banco para cima
- `make migrate-down` - Executar migrações do banco para baixo
- `make migrate-create name=migration_name` - Criar um novo arquivo de migração
- `make install-migrate` - Instalar ferramenta golang-migrate
- `make deps` - Baixar dependências
- `make test` - Executar testes
- `make wire` - Gerar dependências do wire
- `make clean` - Limpar artefatos de build

## Estrutura do Projeto

```
.
├── cmd/
│   └── ordersystem/         # Ponto de entrada da aplicação
├── internal/
│   ├── entity/              # Entidades do domínio
│   ├── event/               # Manipulação de eventos
│   ├── infra/               # Camada de infraestrutura
│   │   ├── database/        # Implementações de banco de dados
│   │   ├── event/           # Implementações de eventos
│   │   ├── graph/           # Implementação GraphQL
│   │   ├── grpc/            # Implementação gRPC
│   │   └── web/             # Implementação Web/REST
│   └── usecase/             # Casos de uso da aplicação
├── migrations/              # Migrações do banco de dados
├── api.http                 # Exemplos de requisições da API
├── docker-compose.yaml      # Configuração do Docker Compose
├── Dockerfile               # Configuração de build do Docker
├── go.mod                   # Definição do módulo Go
├── go.sum                   # Checksums do módulo Go
├── Makefile                 # Comandos de build e desenvolvimento
└── README.md                # Este arquivo
```

## Portas

- REST API: 8000
- gRPC: 50051
- GraphQL: 8080
- MySQL: 3306
- RabbitMQ: 5672 (AMQP), 15672 (Interface de Gerenciamento)
