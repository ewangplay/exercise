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

	queryStr := fmt.Sprintf("select id,uvid from user_behavior where last_time between \"%v\" and \"%v\" and last_source = \"%v\"", "2015-01-19 16:32:04", "2015-01-19 16:38:20", "baidu")
	rows, err := db.Query(queryStr)
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	fmt.Println("查询Mysql数据库Track成功")

	var id int
	var uvid string
	for rows.Next() {
		rerr := rows.Scan(&id, &uvid)
		if rerr == nil {
			fmt.Printf("%v %v\n", id, uvid)
		}
	}
}
