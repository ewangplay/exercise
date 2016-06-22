package main

import (
	"fmt"
)

type IBase interface {
	Func1()
	Func2()
}

type Base struct {
}

func (this *Base) Func1() {
	fmt.Printf("Base: Func1 called\n")
	this.Func2()
}

func (this *Base) Func2() {
	fmt.Printf("Base: Func2 called\n")
}

type Foo struct {
	Base
}

func (this *Foo) Func2() {
	fmt.Printf("Foo: Func2 called\n")
}

func main() {
	var v1, v2 IBase

	v1 = &Base{}
	v2 = &Foo{}

	v1.Func1()
	v2.Func1()
	v2.Func2()
}
