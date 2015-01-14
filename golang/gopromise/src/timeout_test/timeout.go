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

    //针对执行的任务设置了超时时间，如果超时时间到时任务还没有完成，会被取消掉
    //跟调用Cancel的效果一样
    f := promise.Start(task).OnCancel(func() {
        fmt.Println("OnCancel: task cancelled")
    }).SetTimeout(5*1000)

    fmt.Println("task starting ...")

    r, err := f.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)

    //停留两秒钟，否则注册的回调函数来不及执行
    time.Sleep(2 * time.Second)
}

