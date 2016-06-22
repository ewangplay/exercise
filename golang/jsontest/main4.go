package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func main() {
	oriData := ""

	data := []byte(oriData)

	var result interface{}

	err := json.Unmarshal(data, &result)
	if err != nil {
		fmt.Println("解析Json数据失败.", err)
		os.Exit(1)
	}

	fmt.Println(result)
}
