package main

import (
    "fmt"
    "github.com/ewangplay/go-promise"
    "time"
)

func main() {
    fSucc := func(v interface{}) {
        fmt.Println("succ!", v)
    }
    fComplete := func(v interface{}) {
        fmt.Println("complete!", v)
    }
    p := promise.NewPromise().OnSuccess(fSucc).OnComplete(fComplete)

    go func() {
        sum := 0
        for i := 1; i < 10; i++ {
            sum += i
            time.Sleep(time.Second)
        }
        //使用Promise.Resolve()表示任务成功完成
        //使用Promise.Reject()表示任务失败
        p.Resolve(sum)
    }()

    fmt.Println("task starting ...")

    r, err := p.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)

    //停留两秒钟，否则注册的回调函数来不及执行
    time.Sleep(2 * time.Second)
}


