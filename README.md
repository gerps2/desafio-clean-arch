# Sistema de Pedidos

Uma implementação de Clean Architecture para um sistema de gerenciamento de pedidos com interfaces REST API, gRPC e GraphQL.

## Funcionalidades

- **Criar e listar pedidos** com validação completa
- **Múltiplas interfaces de API:**
  - REST API (porta 8000)
  - gRPC (porta 50051) 
  - GraphQL (porta 8080)
- **Arquitetura orientada a eventos** com RabbitMQ
- **Implementação de Clean Architecture** com separação clara de camadas
- **Sistema de configuração inteligente** que detecta ambiente (desenvolvimento/produção)
- **Suporte completo ao Docker** com healthchecks e inicialização automática

## Stack Tecnológica

- **Go 1.23+** - Linguagem principal
- **MySQL 8.0** - Banco de dados relacional
- **RabbitMQ 3.12** - Message broker com interface de gerenciamento
- **Chi Router** - Roteamento HTTP/REST
- **gRPC** - Comunicação de alta performance
- **GraphQL** - API flexível com playground
- **Viper** - Gerenciamento de configuração
- **golang-migrate** - Migrações de banco de dados
- **Docker & Docker Compose** - Containerização e orquestração

## Configuração

### Pré-requisitos

- **Go 1.23+** - Linguagem de programação
- **Docker & Docker Compose** - Para containerização
- **golang-migrate** (opcional para desenvolvimento local)

## Instalação e Execução

### 🚀 Método Recomendado: Docker Compose (Mais Simples)

1. **Clone o repositório:**
```bash
git clone <repository-url>
cd desafio-clean-arch
```

2. **Execute toda a stack:**
```bash
docker-compose up --build
```

✅ **Pronto!** A aplicação estará disponível em:
- REST API: http://localhost:8000
- GraphQL Playground: http://localhost:8080
- gRPC: localhost:50051
- RabbitMQ Management: http://localhost:15672 (guest/guest)

### 🛠️ Desenvolvimento Local

Para desenvolvimento local com hot-reload:

1. **Configure o arquivo de ambiente:**
```bash
# Crie/edite o arquivo cmd/ordersystem/.env
DB_DRIVER=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=orders

WEB_SERVER_PORT=:8000
GRPC_SERVER_PORT=50051
GRAPHQL_SERVER_PORT=8080

RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
RABBITMQ_VHOST=/
```

2. **Inicie apenas a infraestrutura:**
```bash
# Inicia MySQL e RabbitMQ
docker-compose up mysql rabbitmq -d
```

3. **Execute as migrações:**
```bash
make migrate-up
```

4. **Execute a aplicação:**
```bash
make build && make run
```

## 🔧 Sistema de Configuração Inteligente

O sistema detecta automaticamente o ambiente de execução:

### **Produção (Docker)**
- Detecta `GO_ENVIRONMENT=production`
- Carrega configurações das **variáveis de ambiente** do Docker Compose
- Não depende de arquivos `.env`

### **Desenvolvimento (Local)**
- Carrega configurações do arquivo `.env` em `cmd/ordersystem/.env`
- Fallback para variáveis de ambiente do sistema
- Valores padrão para desenvolvimento

### **Variáveis de Ambiente Disponíveis**
```bash
# Ambiente
GO_ENVIRONMENT=production  # Define o modo de operação

# Banco de Dados
DB_DRIVER=mysql
DB_HOST=mysql              # localhost para dev
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=orders

# Servidores
WEB_SERVER_PORT=:8000
GRPC_SERVER_PORT=50051
GRAPHQL_SERVER_PORT=8080

# RabbitMQ
RABBITMQ_HOST=rabbitmq     # localhost para dev
RABBITMQ_PORT=5672
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
RABBITMQ_VHOST=/
```

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

## 🏗️ Arquitetura e Estrutura

### **Clean Architecture**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frameworks    │    │   Interface     │    │    Use Cases    │
│   & Drivers     │◄──►│   Adapters      │◄──►│   (Business     │
│                 │    │                 │    │    Logic)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Controllers   │    │    Entities     │
                       │   Gateways      │    │   (Enterprise   │
                       │   Presenters    │    │  Business Rules)│
                       └─────────────────┘    └─────────────────┘
```

### **Estrutura do Projeto**
```
.
├── cmd/
│   └── ordersystem/         # 🚀 Ponto de entrada da aplicação
│       ├── .env             # 🔧 Configurações de desenvolvimento
│       └── main.go          # 📋 Aplicação principal
├── configs/                 # ⚙️ Sistema de configuração inteligente
│   └── config.go            # 🎛️ Gerenciamento de ambiente
├── internal/
│   ├── entity/              # 🏛️ Entidades do domínio (Clean Architecture)
│   ├── event/               # 📡 Manipulação de eventos (RabbitMQ)
│   ├── infra/               # 🔌 Camada de infraestrutura
│   │   ├── database/        # 🗄️ Implementações de banco de dados
│   │   ├── event/           # 📨 Implementações de eventos
│   │   ├── graph/           # 🕸️ Implementação GraphQL
│   │   ├── grpc/            # ⚡ Implementação gRPC
│   │   └── web/             # 🌐 Implementação Web/REST
│   └── usecase/             # 💼 Casos de uso da aplicação
├── migrations/              # 🗃️ Migrações do banco de dados
├── api.http                 # 📋 Exemplos de requisições da API
├── docker-compose.yaml      # 🐳 Orquestração completa da stack
├── Dockerfile               # 📦 Build otimizado com healthchecks
├── entrypoint.sh            # 🚪 Script de inicialização inteligente
├── .gitignore               # 🚫 Arquivos ignorados pelo Git
├── go.mod                   # 📚 Definição do módulo Go
├── go.sum                   # 🔐 Checksums do módulo Go
├── Makefile                 # 🛠️ Comandos de build e desenvolvimento
└── README.md                # 📖 Este arquivo
```

## 🌐 Portas e Serviços

| Serviço | Porta | URL/Endpoint | Descrição |
|---------|-------|--------------|-----------|
| **REST API** | 8000 | http://localhost:8000 | API RESTful para CRUD de pedidos |
| **GraphQL** | 8080 | http://localhost:8080 | Playground GraphQL interativo |
| **gRPC** | 50051 | localhost:50051 | API gRPC de alta performance |
| **MySQL** | 3306 | localhost:3306 | Banco de dados relacional |
| **RabbitMQ AMQP** | 5672 | localhost:5672 | Message broker |
| **RabbitMQ Management** | 15672 | http://localhost:15672 | Interface web (guest/guest) |

## 🚀 Melhorias Implementadas

### ✅ **Sistema de Configuração Inteligente**
- **Detecção automática de ambiente** (desenvolvimento/produção)
- **Configuração flexível** via arquivos `.env` ou variáveis de ambiente
- **Validação robusta** de configurações obrigatórias
- **Valores padrão** para desenvolvimento rápido

### ✅ **Docker Otimizado**
- **Healthchecks** para MySQL e RabbitMQ
- **Entrypoint script** inteligente com verificação de dependências
- **Build multi-stage** para imagens menores
- **Inicialização automática** de migrações

### ✅ **Configuração RabbitMQ Completa**
- **Suporte completo** a diferentes ambientes
- **Configuração flexível** de host, porta, usuário e vhost
- **Conexão robusta** com tratamento de erros
- **Integração seamless** com Docker Compose

### ✅ **Melhorias de Código**
- **Estrutura de configuração** tipada e validada
- **Tratamento de erros** aprimorado
- **Logs informativos** para debugging
- **Código mais limpo** e organizad
