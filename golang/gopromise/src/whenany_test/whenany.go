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

    //WhenAny只要任一任务完成就会返回
    //因为task1先完成，所以f.Get的返回值为45
    f := promise.WhenAny(task1, task2)

    fmt.Println("task1 starting ...")
    fmt.Println("task2 starting ...")

    r, err := f.Get()
    if err != nil {
        fmt.Println("Get value fail.", err)
    }
    fmt.Println(r)
}


