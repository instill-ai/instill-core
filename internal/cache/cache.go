package cache

import (
	"github.com/go-redis/redis/v8"
	"github.com/instill-ai/visual-data-preparation/configs"
)

var Redis *redis.Client

func Init() {
	Redis = redis.NewClient(&configs.Config.Cache.Redis.RedisOptions)
}

func Close() {
	if Redis != nil {
		Redis.Close()
	}
}
