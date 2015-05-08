package main

import (
	"fmt"
	"github.com/ewangplay/go-logger"
	"os"
)

func main() {
	var mylogger *logger.Logger
	var err error

	mylogger, err = logger.New("1.log", 1)
	if err != nil {
		fmt.Println("Open log file fail.", err)
		os.Exit(1)
	}

	v1 := "hello"
	v2 := 23
	v3 := []string{"name1", "name2", "name3"}
	v4 := map[string]interface{}{"test1": v1, "test2": v2, "test3": v3}

	mylogger.Debugf("this is a test: %v - %v - %v - %v", v1, v2, v3, v4)
	mylogger.Infof("this is a test: %v - %v - %v - %v", v1, v2, v3, v4)
	mylogger.Errorf("this is a test: %v - %v - %v - %v", v1, v2, v3, v4)
}
