package main

import (
    "fmt"
    "encoding/json"
    "os"
)

func main() {
    oriData := `{"urls":[
    {"object_type":"","result":true,"url_short":"http://t.cn/RzlP1E0","object_id":"","url_long":"http://github.com/ewangplay/shorturl","type":0}
    ]}`

    data := []byte(oriData)

    var result map[string][]map[string]interface{}

    err := json.Unmarshal(data, &result)
    if err != nil {
        fmt.Println("解析Json数据失败.", err)
        os.Exit(1)
    }

    fmt.Println(result)

    fmt.Println(result["urls"][0]["url_short"])
}

