package configs

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	DBDriver          string `mapstructure:"DB_DRIVER"`
	DBHost            string `mapstructure:"DB_HOST"`
	DBPort            string `mapstructure:"DB_PORT"`
	DBUser            string `mapstructure:"DB_USER"`
	DBPassword        string `mapstructure:"DB_PASSWORD"`
	DBName            string `mapstructure:"DB_NAME"`
	WebServerPort     string `mapstructure:"WEB_SERVER_PORT"`
	GRPCServerPort    string `mapstructure:"GRPC_SERVER_PORT"`
	GraphQLServerPort string `mapstructure:"GRAPHQL_SERVER_PORT"`

	RabbitHost     string `mapstructure:"RABBITMQ_HOST"`
	RabbitPort     string `mapstructure:"RABBITMQ_PORT"`
	RabbitUser     string `mapstructure:"RABBITMQ_USER"`
	RabbitPassword string `mapstructure:"RABBITMQ_PASSWORD"`
	RabbitVHost    string `mapstructure:"RABBITMQ_VHOST"`
}

func LoadConfig(searchPath string) (*Config, error) {
	goEnv := os.Getenv("GO_ENVIRONMENT")

	// 1) Sempre habilita env
	viper.AutomaticEnv()

	// 2) BindEnv garante que as chaves existem dentro do Viper para o Unmarshal
	_ = viper.BindEnv("DB_DRIVER")
	_ = viper.BindEnv("DB_HOST")
	_ = viper.BindEnv("DB_PORT")
	_ = viper.BindEnv("DB_USER")
	_ = viper.BindEnv("DB_PASSWORD")
	_ = viper.BindEnv("DB_NAME")

	_ = viper.BindEnv("WEB_SERVER_PORT")
	_ = viper.BindEnv("GRPC_SERVER_PORT")
	_ = viper.BindEnv("GRAPHQL_SERVER_PORT")

	_ = viper.BindEnv("RABBITMQ_HOST")
	_ = viper.BindEnv("RABBITMQ_PORT")
	_ = viper.BindEnv("RABBITMQ_USER")
	_ = viper.BindEnv("RABBITMQ_PASSWORD")
	_ = viper.BindEnv("RABBITMQ_VHOST")

	// 3) Em dev, tenta .env se existir (não afeta produção)
	if goEnv != "production" {
		candidates := []string{
			filepath.Join(searchPath, ".env"),
			filepath.Join(searchPath, "app_config.env"),
			"cmd/ordersystem/.env",
		}
		for _, f := range candidates {
			if st, err := os.Stat(f); err == nil && !st.IsDir() {
				viper.SetConfigFile(f)
				_ = viper.ReadInConfig()
				break
			}
		}
	}

	// 4) Defaults (não sobrepõem env/.env)
	viper.SetDefault("WEB_SERVER_PORT", ":8000")
	viper.SetDefault("GRPC_SERVER_PORT", "50051")
	viper.SetDefault("GRAPHQL_SERVER_PORT", "8080")
	viper.SetDefault("RABBITMQ_HOST", "rabbitmq")
	viper.SetDefault("RABBITMQ_PORT", "5672")
	viper.SetDefault("RABBITMQ_USER", "guest")
	viper.SetDefault("RABBITMQ_PASSWORD", "guest")
	viper.SetDefault("RABBITMQ_VHOST", "/")

	// 5) Deserializa
	var cfg Config
	if err := viper.Unmarshal(&cfg); err != nil {
		return nil, err
	}

	// Normalizações/validações
	if cfg.WebServerPort != "" && !strings.HasPrefix(cfg.WebServerPort, ":") {
		cfg.WebServerPort = ":" + cfg.WebServerPort
	}
	if cfg.DBDriver == "" {
		return nil, fmt.Errorf("DB_DRIVER is empty (env or .env)")
	}
	if cfg.DBHost == "" || cfg.DBPort == "" || cfg.DBUser == "" || cfg.DBName == "" {
		return nil, fmt.Errorf("database config incomplete (env or .env)")
	}
	if cfg.RabbitHost == "" || cfg.RabbitPort == "" {
		return nil, fmt.Errorf("rabbitmq config incomplete (env or .env)")
	}

	// Log resumido (ok deixar em produção por enquanto)
	fmt.Printf("=== CONFIG ===\n")
	fmt.Printf("ENV: %s | DB: %s@%s:%s/%s | HTTP: %s | gRPC: %s | GraphQL: %s\n",
		goEnv, cfg.DBUser, cfg.DBHost, cfg.DBPort, cfg.DBName,
		cfg.WebServerPort, cfg.GRPCServerPort, cfg.GraphQLServerPort)
	fmt.Printf("RabbitMQ: %s:%s vhost=%s user=%s\n", cfg.RabbitHost, cfg.RabbitPort, cfg.RabbitVHost, cfg.RabbitUser)
	fmt.Printf("==============\n")

	return &cfg, nil
}
