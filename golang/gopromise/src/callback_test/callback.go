package main

import (
    "fmt"
    "github.com/ewangplay/go-promise"
    "time"
)

func main() {
    task := func()(interface{}, error){
        sum := 0
        for i := 1; i < 10; i++ {
            sum += i
            time.Sleep(time.Second)
        }
        return sum, nil
    }

    f := promise.Start(task).OnComplete(func(v interface{}) {
        fmt.Println("complete!", v)
    }).OnSuccess(func(v interface{}) {
        fmt.Println("succ!", v)
    })

    fmt.Println("task starting ...")

    r, err := f.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)

    //停留两秒钟，否则注册的回调函数来不及执行
    time.Sleep(2 * time.Second)
}


