package main

import (
    "fmt"
    "github.com/ewangplay/go-promise"
    "time"
)

func main() {
    task := func(canceller promise.Canceller)(interface{}, error){
        sum := 0
        for i := 1; i < 10; i++ {
            if canceller.IsCancelled() {
                return 0, nil
            }
            sum += i
            time.Sleep(time.Second)
        }
        return sum, nil
    }

    f := promise.Start(task).OnCancel(func() {
        fmt.Println("OnCancel: task cancelled")
    })

    fmt.Println("task starting ...")
    f.Cancel()
    fmt.Println("task cancelled")

    r, err := f.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)

    //停留两秒钟，否则注册的回调函数来不及执行
    time.Sleep(2 * time.Second)
}

