package main

import (
	"bufio"
	"fmt"
	"github.com/bitly/go-nsq"
	"io"
	"os"
	"strings"
)

type myHandler struct{}

func (h *myHandler) HandleMessage(m *nsq.Message) error {
	fmt.Println(string(m.Body))
	return nil
}

func main() {
	if len(os.Args) != 3 {
		fmt.Printf("usage: %v <127.0.0.1:4150> <topic>\n", os.Args[0])
		os.Exit(1)
	}

	netAddr := os.Args[1]
	topic := os.Args[2]

	cfg := nsq.NewConfig()

	p, err := nsq.NewProducer(netAddr, cfg)
	if err != nil {
		fmt.Printf("new producer fail. %v\n", err)
		os.Exit(1)
	}

	bio := bufio.NewReader(os.Stdin)

	for i := 0; i < 5; i++ {
		line, err := bio.ReadString('\n')
		if err != nil || err == io.EOF {
			break
		}

		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		msg := fmt.Sprintf("%v: %v", i, line)

		err = p.Publish(topic, []byte(msg))
		if err != nil {
			fmt.Printf("publish message[%v] fail: %v\n", msg, err)
			break
		}
	}

	p.Stop()
}
