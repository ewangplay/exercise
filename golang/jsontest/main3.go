package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func main() {

	/*
		mBody := map[string]interface{}{
			"group": map[string]string{
				"id":   "123",
				"name": "group01",
			},
		}
	*/

	var mBody map[string]interface{}

	body, err := json.Marshal(mBody)
	if err != nil {
		fmt.Printf("call json.Marshal fail: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(string(body))
}
