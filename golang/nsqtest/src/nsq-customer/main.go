package main

import (
	"fmt"
	"github.com/bitly/go-nsq"
	"os"
)

type myHandler struct{}

func (h *myHandler) HandleMessage(m *nsq.Message) error {
	fmt.Println(string(m.Body))
	return nil
}

func main() {
	if len(os.Args) != 4 {
		fmt.Printf("usage: %v <127.0.0.1:4161> <topic> <channel>\n", os.Args[0])
		os.Exit(1)
	}

	netAddr := os.Args[1]
	topic := os.Args[2]
	channel := os.Args[3]

	cfg := nsq.NewConfig()
	cfg.MaxInFlight = 1000

	c, err := nsq.NewConsumer(topic, channel, cfg)
	if err != nil {
		fmt.Printf("new coustomer fail. %v\n", err)
		os.Exit(1)
	}
	c.AddHandler(&myHandler{})

	err = c.ConnectToNSQLookupd(netAddr)
	if err != nil {
		fmt.Printf("connect to nsq lookupd fail. %v\n", err)
		os.Exit(1)
	}

	<-c.StopChan
}
