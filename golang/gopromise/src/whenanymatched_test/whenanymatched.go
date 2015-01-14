package main

import (
    "fmt"
    "github.com/ewangplay/go-promise"
    "time"
)

func main() {
    task1 := func()(interface{}, error){
        sum := 0
        for i := 1; i < 10; i++ {
            sum += i
            time.Sleep(time.Second)
        }
        return sum, nil //返回45
    }

    task2 := func()(interface{}, error) {
        sum := 0
        for i := 1; i < 15; i++ {
            sum += i
            time.Sleep(time.Second)
        }
        return sum, nil //返回105
    }

    //如果没有任何任务的返回结果匹配该断言，那么返回error("No matched future")
    f := promise.WhenAnyMatched(func(v interface{}) bool {
        return v == 45  //这个断言会导致f.Get返回45
        return v == 105 //这个断言会导致f.Get返回105
        return v == 100 //这个断言会导致f.Get的结果返回error("No matched future")
    }, task1, task2)

    fmt.Println("task1 starting ...")
    fmt.Println("task2 starting ...")

    r, err := f.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)
}


