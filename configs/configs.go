package configs

import (
	"flag"
	"os"
	"strings"

	"github.com/go-redis/redis/v8"
	"github.com/instill-ai/visual-data-pipeline/internal/logger"
	"github.com/knadh/koanf"
	"github.com/knadh/koanf/parsers/yaml"
	"github.com/knadh/koanf/providers/env"
	"github.com/knadh/koanf/providers/file"
	"go.temporal.io/sdk/client"
)

// Config : application config stored as global variable
var Config AppConfig

type AppConfig struct {
	Temporal TemporalConfig
	VDO      VDOConfig
	Cache    CacheConfig
}

// TemporalConfig :
type TemporalConfig struct {
	ClientOptions    client.Options
	NamespaceOptions NamespaceOptions
}

type NamespaceOptions struct {
	Retentionhour int
}

type VDOConfig struct {
	Scheme string
	Host   string
	Port   int
	Path   string
}

type CacheConfig struct {
	Redis struct {
		RedisOptions redis.Options
	}
}

// Init - Assign global config to decoded config struct
func Init() error {
	logger, _ := logger.GetZapLogger()

	k := koanf.New(".")
	parser := yaml.Parser()

	fs := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fileRelativePath := fs.String("file", "configs/config.yaml", "configuration file")
	flag.Parse()

	if err := k.Load(file.Provider(*fileRelativePath), parser); err != nil {
		logger.Fatal(err.Error())
	}

	k.Load(env.Provider("CFG_", ".", func(s string) string {
		return strings.Replace(strings.ToLower(
			strings.TrimPrefix(s, "CFG_")), "_", ".", -1)
	}), nil)

	k.Unmarshal("", &Config)

	return ValidateConfig(&Config)
}

// ValidateConfig is for custom validation rules for the configuration
func ValidateConfig(cfg *AppConfig) error {
	return nil
}
