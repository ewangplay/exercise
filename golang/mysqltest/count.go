package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	db, err := sql.Open("mysql", "root:123456@tcp(localhost:3306)/track?charset=utf8")
	if err != nil {
		panic(err)
	}
	defer db.Close()

	fmt.Println("连接Mysql数据库成功")

	rows, err := db.Query("select count(uvid) from user_behavior where last_source=\"weibo\"")
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	fmt.Println("查询Mysql数据库Track成功")

	var count int
	for rows.Next() {
		rerr := rows.Scan(&count)
		if rerr == nil {
			fmt.Printf("%v\n", count)
		}
	}
}
