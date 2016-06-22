package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Person struct {
	Id   string
	Name string
}

func main() {
	/*
		mBody := map[string]string{
			"openid": "12345678",
			"remark": "panzi",
		}
	*/
	/*
		mBody := map[string]interface{}{
			"group": map[string]string{
				"id":   "123",
				"name": "group01",
			},
		}
	*/

	mBody := Person{
		Id:   "123",
		Name: "xiaoming",
	}

	body, err := json.Marshal(&mBody)
	if err != nil {
		fmt.Printf("call json.Marshal fail: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(string(body))
}
