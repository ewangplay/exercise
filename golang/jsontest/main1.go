package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type SMSResult_Wxtl struct {
	Status string
	Data   []map[string]string
	Size   string
}

func main() {
	oriData := `{"status":"0","data":[{"pktotal":"1","status":"2","ssid":"10","csid":"2679345828356899","errorcode":"-29","pknumber":"1","custom":"","mobile":"13401173761"},{"pktotal":"1","status":"2","ssid":"9","csid":"2679345828356898","errorcode":"-29","pknumber":"1","custom":"","mobile":"13401173761"}],"size":"2"}`

	data := []byte(oriData)

	var result SMSResult_Wxtl
	err := json.Unmarshal(data, &result)
	if err != nil {
		fmt.Println("解析Json数据失败.", err)
		os.Exit(1)
	}

	fmt.Println(result)

	for _, data := range result.Data {
		for k, v := range data {
			fmt.Println(k, ": ", v)
		}
	}
}
