package main

import (
	"fmt"
	"github.com/garyburd/redigo/redis"
)

func main() {
	conn, err := redis.Dial("tcp", "10.254.33.20:32079")
	if err != nil {
		fmt.Println("connect to redis server fail.", err)
		return
	}

	_, err = conn.Do("SET", "003:mail", "0")
	if err != nil {
		fmt.Println("set key 003:mail fail.", err)
		return
	}

	ok, err := redis.Bool(conn.Do("INCR", "003:mail"))
	if err != nil {
		fmt.Println("incr key 003:mail fail.", err)
		return
	}
	if ok {
		fmt.Println("incr key 003:mail succ.")
	}

	count, err := redis.Int64(conn.Do("GET", "001:mail"))
	if err != nil {
		fmt.Println("get key 001:mail fail.", err)
		return
	}

	fmt.Println("key=001:mail, value=", count)
}
