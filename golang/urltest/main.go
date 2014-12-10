package main

import (
    fm "fmt"
    "net/url"
)

func main() {
    var urlStr string = "http://211.152.9.213:6600/Send.aspx?CorpID=ysxz&Pwd=ysxz123&Mobile=13401173761&Content=这是一个测试&Cell=&SendTime="
    /*
    l, err := url.ParseQuery(urlStr)
    fm.Println(l, err)
    l2, err2 := url.ParseRequestURI(urlStr)
    fm.Println(l2, err2)
    */

    l3, err3 := url.Parse(urlStr)
    fm.Println(l3, err3)
    //fm.Println(l3.Path)
    //fm.Println(l3.RawQuery)
    //fm.Println(l3.Query())
    //fm.Println(l3.Query().Encode())
    //fm.Println(l3.RequestURI())
    fm.Println()
    fm.Printf("%s//%s%s?%s", l3.Scheme, l3.Host, l3.Path, l3.Query().Encode())
}
