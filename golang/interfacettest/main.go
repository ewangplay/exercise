package main

import (
    "fmt"
)

type I interface {
    Get() int
    Set(int)
}

type P struct { i int }
func (p *P)Get() int {
    return p.i
}
func (p *P)Set(num int) {
    p.i = num
}

func fn(t I) {
    fmt.Println(t.Get())
    t.Set(2)
}

func main() {
    p := P{1}
    fmt.Println(p)
    fn(&p)
    fmt.Println(p)
}

