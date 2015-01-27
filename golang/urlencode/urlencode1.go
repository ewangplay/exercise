package main

import (
	"fmt"
	"net/url"
	"os"
	"strings"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Println("usage: base64tool <src_str>")
		os.Exit(1)
	}

	src_str := os.Args[1]

	fmt.Println("Origin String: ", src_str)

	base64_str := url_encode(src_str)

	fmt.Println("Base64 String: ", base64_str)
}

func url_encode(src string) string {

	v := url.Values{}
	v.Set("v", src)
	s := strings.FieldsFunc(v.Encode(), func(c rune) bool {
		return c == '='
	})
	return s[1]
}
