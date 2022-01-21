package configs

import (
	"flag"
	"log"
	"os"

	"github.com/go-redis/redis/v8"
	"github.com/jinzhu/configor"
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

// assign global config to decoded config struct
func Init() error {
	fs := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fileRelativePath := fs.String("file", "configs/config.yaml", "configuration file")
	flag.Parse()
	// Remove special `CONFIGOR` prefix for extracting variables from os environment purpose
	os.Setenv("CONFIGOR_ENV_PREFIX", "-")
	// For some reason, you can pass env to switch to different configurations
	env, _ := os.LookupEnv("ENV")
	// Load from default path, or you can use `-file=xxx` to another file
	if err := configor.New(&configor.Config{Environment: env}).Load(&Config, *fileRelativePath); err != nil {
		log.Fatal(err)
	}

	return ValidateConfig(&Config)
}

// ValidateConfig is for custom validation rules for the configuration
func ValidateConfig(cfg *AppConfig) error {
	return nil
}
