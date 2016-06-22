package main

import (
	"fmt"
)

func main() {
	v := map[string]interface{}{
		"type": 1,
	}

	type_int, ok := v["type"].(int)
	if !ok {
		fmt.Printf("type convert to int fail: %v\n", type_int)
	} else {
		fmt.Printf("type convert to int succ: %v\n", type_int)
	}

	type_int8, ok := v["type"].(int8)
	if !ok {
		fmt.Printf("type convert to int8 fail: %v\n", type_int8)
	} else {
		fmt.Printf("type convert to int8 succ: %v\n", type_int8)
	}

	type_int16, ok := v["type"].(int16)
	if !ok {
		fmt.Printf("type convert to int16 fail: %v\n", type_int16)
	} else {
		fmt.Printf("type convert to int16 succ: %v\n", type_int16)
	}

	type_int64, ok := v["type"].(int64)
	if !ok {
		fmt.Printf("type convert to int64 fail: %v\n", type_int64)
	} else {
		fmt.Printf("type convert to int64 succ: %v\n", type_int64)
	}

	type_int32, ok := v["type"].(int32)
	if !ok {
		fmt.Printf("type convert to int32 fail: %v\n", type_int32)
	} else {
		fmt.Printf("type convert to int32 succ: %v\n", type_int32)
	}

	type_str, ok := v["type"].(string)
	if !ok {
		fmt.Printf("type convert to string fail: %v\n", type_str)
	} else {
		fmt.Printf("type convert to string succ: %v\n", type_str)
	}

	type_bool, ok := v["type"].(bool)
	if !ok {
		fmt.Printf("type convert to bool fail: %v\n", type_bool)
	} else {
		fmt.Printf("type convert to bool succ: %v\n", type_bool)
	}

}
