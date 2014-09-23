//Study Go->Q2
package main

import (
	"fmt"
)

func main() {
    //Q2-1
    func1()

    //Q2-2
    func2()

    //Q2-3
    func3()
}

func func1() {
    for i:=0; i<10; i++ {
        if i < 9 {
            fmt.Print(i, " ")
        } else {
            fmt.Println(i)
        }
    }
}

func func2() {
    i := 0
    BEGIN:
    if i < 9 {
        fmt.Print(i, " ")
    } else {
        fmt.Println(i)
    }

    i++
    if i<10 {
        goto BEGIN
    }
}

func func3() {
    a := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
    for _,v := range a {
        if v < 9 {
            fmt.Print(v, " ")
        } else {
            fmt.Println(v)
        }
    }
}

