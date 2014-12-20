package main

import (
    "fmt"
    "sort"
    "os"
    "strings"
    "unicode"
    "io/ioutil"
    "path/filepath"
    "log"
    "strconv"
)

type Book struct {
    Name string
    Price float64
}

type BookList []Book
func (list BookList) Len() int { return len(list) }
func (list BookList) Less(i,j int) bool {
    return list[i].Price > list[j].Price
}
func (list BookList) Swap(i,j int) {
    list[i], list[j] = list[j], list[i]
}

type GroupList []BookList
func (list GroupList) Len() int { return len(list) }
func (list GroupList) Less(i,j int) bool {
    sum1 := getSum(list[i])
    sum2 := getSum(list[j])
    return sum1 > sum2
}
func (list GroupList) Swap(i,j int) {
    list[i], list[j] = list[j], list[i]
}

/*
books_list := BookList{
    {"算法导论" , 103.10},
    {"数据挖掘与R语言" , 39.50},
    {"人件（原书第3版）" , 56.20},
    {"设计原本" , 63.60 },
    {"用户体验要素：以用户为中心的产品设计（原书第2版）" , 31.40},
    {"数据挖掘：概念与技术（原书第3版）" , 63.60},
    {"并行程序设计导论" , 39.50},
    {"机器学习／计算机科学丛书" , 28.20},
    {"JavaScript权威指南（第6版）" , 111.90},
    {"HTML5 Canvas核心技术：图形、动画与游戏开发" , 79.70},
    {"测试驱动的JavaScript开发" , 49.30},
    {"图灵程序设计丛书：MongoDB权威指南（第2版）", 64.60},
}
*/
func main() {
    if len(os.Args) == 1 {
        fmt.Printf("usage: %s <book_list_file>\n", filepath.Base(os.Args[0]))
        os.Exit(1)
    }

    var books_list BookList
    if rawBytes, err := ioutil.ReadFile(os.Args[1]); err != nil {
        log.Fatal(err)
    } else {
        books_list = readBookList(string(rawBytes))
    }

    for _,v := range books_list {
        fmt.Println(v.Name, "\t", v.Price)
    }
    fmt.Println()

    sort.Sort(books_list)

    group_num := eval_group_num(books_list)

    groups_list := make([]BookList, group_num)
    for i := range groups_list {
        groups_list[i] = make([]Book, 0)
    }

    for _, book := range books_list {
        select_group(groups_list, book)
    }

    sort.Sort(GroupList(groups_list))

    for i, v := range groups_list {
        fmt.Println("==================== ", i + 1, " ====================")
        for _, book := range v {
            fmt.Println(book.Name, "\t", book.Price)
        }
        fmt.Println("总计: ", getSum(v))
        fmt.Println()
    }
}

func eval_group_num(books_list BookList) int {
    var sum float64
    for _, book := range books_list {
        sum += book.Price
    }
    return int(sum / 199)
}

func select_group(group_list []BookList, book_item Book) {
    sort.Sort(GroupList(group_list))

    tmp_sum := make([]float64, len(group_list))

    append_succ := false
    for i := range group_list {
        if tmp_sum[i] = getSum(group_list[i]) + book_item.Price; tmp_sum[i] < 199 {
            group_list[i] = append(group_list[i], book_item)
            append_succ = true
            break
        }
    }

    if ! append_succ {
        i := getMinSumGroupIndex(tmp_sum)
        group_list[i] = append(group_list[i], book_item)
    }
}

func getMinSumGroupIndex(list []float64) int {
    index := 0
    for i, v := range list {
        if list[index] > v {
            index = i
        }
    }
    return index
}

func getSum(books_list BookList) float64 {
    var sum float64
    for _,book := range books_list {
        sum += book.Price
    }
    return sum
}

func readBookList(data string) (book_list BookList) {
    var book Book
    for _, line := range strings.Split(data, "\n") {
        line = strings.TrimSpace(line)
        if line == "" {
            continue
        }

        fields := strings.FieldsFunc(line, func (char rune) bool {
            return unicode.IsSpace(char)
        })

        if fields[0] != "" {
            book.Name = fields[0]
        }
        if fields[1] != "" {
            book.Price, _ = strconv.ParseFloat(fields[1], 64)
        }

        if book.Name != "" && book.Price != 0.0 {
            book_list = append(book_list, book)
            book = Book{}
        }
    }
    return book_list
}

