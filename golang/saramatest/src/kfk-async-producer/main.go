package main

import (
	"bufio"
	"fmt"
	"github.com/Shopify/sarama"
	"io"
	"os"
	"strings"
)

type MyData struct {
	Data string
}

func (this MyData) Encode() ([]byte, error) {
	return []byte(this.Data), nil
}

func (this MyData) Length() int {
	return len(this.Data)
}

func main() {
	if len(os.Args) != 3 {
		fmt.Printf("usage: %v <10.254.34.40:9092> <topic>\n", os.Args[0])
		os.Exit(1)
	}

	netAddr := os.Args[1]
	topic := os.Args[2]

	cfg := sarama.NewConfig()
	cfg.Producer.Partitioner = sarama.NewRandomPartitioner

	p, err := sarama.NewSyncProducer([]string{netAddr}, cfg)
	if err != nil {
		fmt.Printf("new producer fail. %v\n", err)
		os.Exit(1)
	}
	defer p.Close()

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

		fmt.Printf("input msg: %v\n", line)

		key := fmt.Sprintf("%v", i)
		msg := &sarama.ProducerMessage{
			Topic: topic,
			Key:   MyData{key},
			Value: MyData{line},
		}

		partition, offset, err := p.SendMessage(msg)
		if err != nil {
			fmt.Printf("publish message[%v] fail: %v\n", line, err)
			break
		}

		fmt.Printf("publish message succ. partition: %v, offset: %v\n", partition, offset)
	}

}
