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

    f := promise.Start(task)

    fmt.Println("task starting ...")

    //调用Future.Get()方法时会阻塞当前的goroutine，直到任务完成或取消
    r, err := f.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)
}


