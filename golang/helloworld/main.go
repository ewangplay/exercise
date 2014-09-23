// helloworld project main.go
package main

import (
	"fmt"
)

func main() {
	fmt.Println("Hello World!")

    a, b := 1, 2
	c, d := a + b, a - b
	fmt.Println("1 + 2 = ", c)
	fmt.Println("1 - 2 = ", d)

    s1 := "hello"
    b1 := []byte(s1)
    b1[0] = 'w'
    s2 := string(b1)
    fmt.Println("s1 = ", s1)
    fmt.Println("s2 = ", s2)

    var (
        /*
        n1 int
        n2 int32
        */
        n1, n2 int32
        n3 bool
    )
    n1 = 5
    n2 = 5
    n3 = (n1 == n2)  /* build error for mismatched types compare */
    fmt.Println("n3 = ", n3)
}
