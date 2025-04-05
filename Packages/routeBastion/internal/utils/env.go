package utils

import "github.com/spf13/viper"

type AppEnvConfig struct {
	DBUsername string `mapstructure:"DB_USERNAME"`
	DBPassword string `mapstructure:"DB_PASSWORD"`
	DBHost     string `mapstructure:"DB_HOST"`
	DBPort     string `mapstructure:"DB_PORT"`
	DBDatabase string `mapstructure:"DB_DATABASE"`
	DBSchema   string `mapstructure:"DB_SCHEMA"`
	ServerPort string `mapstructure:"SERVER_PORT"`
}

func LoadConfig(path string) (config AppEnvConfig, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
