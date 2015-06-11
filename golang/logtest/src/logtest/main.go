package main

import (
	"fmt"
	"github.com/ewangplay/go-logger"
	"os"
)

var g_logger *logger.Logger

func main() {
	var err error

	g_logger, err = logger.New("1.log", 1)
	if err != nil {
		fmt.Println("Open log file fail.", err)
		os.Exit(1)
	}

	v1 := "hello"
	v2 := 23
	v3 := []string{"name1", "name2", "name3"}
	v4 := map[string]interface{}{"test1": v1, "test2": v2, "test3": v3}

	LOG_DEBUG("this is a test: %v - %v - %v - %v", v1, v2, v3, v4)
	LOG_INFO("this is a test: %v - %v - %v - %v", v1, v2, v3, v4)
	LOG_ERROR("this is a test: %v - %v - %v - %v", v1, v2, v3, v4)
	LOG_DEBUG("I have no param!")
	LOG_INFO("I have no param!")
	LOG_ERROR("I have no param!")

}

func LOG_DEBUG(format string, a ...interface{}) {
	if DEBUG() {
		g_logger.Debugf(format, a...)
	}
}

func LOG_INFO(format string, a ...interface{}) {
	if INFO() {
		g_logger.Infof(format, a...)
	}
}

func LOG_WARN(format string, a ...interface{}) {
	if WARN() {
		g_logger.Warningf(format, a...)
	}
}

func LOG_ERROR(format string, a ...interface{}) {
	if ERROR() {
		g_logger.Errorf(format, a...)
	}
}

func DEBUG() bool {
	return true
}

func INFO() bool {
	return true
}

func WARN() bool {
	return true
}

func ERROR() bool {
	return true
}
