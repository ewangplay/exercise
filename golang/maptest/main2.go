package main

import (
	"fmt"
)

func main() {
	m1 := make(map[string]string)
	fmt.Println(len(m1))
	m1["a"] = "tom"
	m1["b"] = "cap"
	fmt.Println(len(m1))
	delete(m1, "b")
	fmt.Println(len(m1))

	m2 := make(map[string]string, 10)
	fmt.Println(len(m2))
	m2["b"] = "cap"
	fmt.Println(len(m2))
}
