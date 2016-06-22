package main

import (
//"fmt"
)

func main() {
	result := make(map[string]interface{})

	result["list"] = make([]map[string]string, 10)

	for i := 0; i < 10; i++ {
		v, ok := result["list"].([]map[string]string)
		if ok {
			v[i] = make(map[string]string)

			v[i]["key1"] = "test1"

		}
	}
}
