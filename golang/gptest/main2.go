package main

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"gopkg.in/pg.v3"
)

type jsonMap map[string]interface{}

func (m *jsonMap) Scan(value interface{}) error {
	return json.Unmarshal(value.([]byte), m)
}

func (m jsonMap) Value() (driver.Value, error) {
	b, err := json.Marshal(m)
	if err != nil {
		return nil, err
	}
	return string(b), nil
}

type Item struct {
	Id   int64
	Data jsonMap
}

type Items struct {
	C []Item
}

var _ pg.Collection = &Items{}

func (items *Items) NewRecord() interface{} {
	items.C = append(items.C, Item{})
	return &items.C[len(items.C)-1]
}

func CreateItem(db *pg.DB, item *Item) error {
	_, err := db.ExecOne(`INSERT INTO items VALUES (?id, ?data)`, item)
	return err
}

func GetItem(db *pg.DB, id int64) (*Item, error) {
	item := &Item{}
	_, err := db.QueryOne(item, `
    SELECT * FROM items WHERE id = ?
    `, id)
	return item, err
}

func GetItems(db *pg.DB) ([]Item, error) {
	var items Items
	_, err := db.Query(&items, `
    SELECT * FROM items
    `)
	return items.C, err
}

func main() {
	db := pg.Connect(&pg.Options{
		Host:     "10.254.34.40",
		Port:     "2345",
		User:     "gpadmin",
		Password: "gpadmin",
		Database: "jzl_db",
	})
	defer db.Close()

	_, err := db.Exec(`CREATE TABLE items (id serial, data text)`)
	if err != nil {
		panic(err)
	}

	item := &Item{
		Id:   1,
		Data: jsonMap{"hello": "world"},
	}
	if err := CreateItem(db, item); err != nil {
		panic(err)
	}

	item, err = GetItem(db, 1)
	if err != nil {
		panic(err)
	}
	fmt.Println(item)
}
