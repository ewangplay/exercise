// Study Go -> Q4
package main

import (
	"fmt"
)

func main() {
    //Q4-1
    func1()

    //Q4-2
    func2()

    //Q4-3
    func3()
}

func func1() {
    str := "A"
    for i:=1; i<=100; i++ {
        fmt.Println(str)
        str += "A"
    }
}

func func2() {
    s := "asSASA ddd dsjkdsjs dk"
    m := make(map[string]int)

    for _,v := range s {
        m[string(v)]++
    }

    for k,v := range m {
        fmt.Printf("character %s num: %d\n", k, v)
    }
}

func func3() {
    s := "asSASA ddd dsjkdsjs dk"
    s1 := []byte(s)
    n1 := copy(s1[4:], []byte("abc"))
    fmt.Printf("replace characters num %d, new string is %s\n", n1, s1)
}

