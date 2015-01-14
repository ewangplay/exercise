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

    task2 := func(v interface{})(interface{}, error) {
        sum := 0
        for i := 1; i < v.(int); i++ {
            sum += i
            time.Sleep(time.Second)
        }
        return sum, nil //返回
    }

    //通过Pipe可以把前面任务执行完后返回的结果通过参数传递给下一个任务
    f, ok := promise.Start(task1).Pipe(task2)
    if ok {
        fmt.Println("task1 starting ...")
        fmt.Println("task2 starting ...")

        r, err := f.Get()
        if err != nil {
            fmt.Println("Get value fail.", err)
        }
        fmt.Println(r)
    }
}

