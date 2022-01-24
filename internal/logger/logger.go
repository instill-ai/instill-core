package logger

import (
	"sync"

	"go.uber.org/zap"
)

var logger *zap.Logger
var once sync.Once

func GetZapLogger() (*zap.Logger, error) {
	var err error
	once.Do(func() {
		logger, err = zap.NewProduction()
	})

	return logger, err
}
