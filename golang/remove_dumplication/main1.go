package main

import (
    "fmt"
    "sort"
)

func main() {
    li := []string{

        "hello", "world", "tom", "marry", "tom", "nihao", "harry", "world", "haha",

    }

    fmt.Println(li)
    fmt.Println(len(li))

    ret_li := RemoveArbitraryDuplication(li)

    fmt.Println(ret_li)
    fmt.Println(len(ret_li))
}

func RemoveArbitraryDuplication(a []string) (ret []string) {
    tmp_map := make(map[string]int, 0)
    for _, i := range a {
        tmp_map[i] = 1
    }

    for k, _ := range tmp_map {
        ret = append(ret, k)
    }
    
    sort.Strings(ret)

    return
}
