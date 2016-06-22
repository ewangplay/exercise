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

	//消息写入kafka partition的策略：
	//1. Random模式：通过fg.Producer.Partitioner = sarama.NewRandomPartitioner来指定，
	//              这种模式下消息会随机的分配到topic的不同partition里
	//2. Manual模式：通过cfg.Producer.Partitioner = sarama.NewManualPartitioner来指定，
	//              这种模式下需要开发者手动来指定消息要写入的partition，如果不指定，那么默认写到第一个partition里
	//3. Hash模式：不指定上面两种模式的情况下，如果设置了消息的Key字段，那么按照key做Hash运算，对应到指定的Partition，
	//              也就是说，消息的Key固定，那么写入到哪个partition也固定了。
	cfg := sarama.NewConfig()
	//cfg.Producer.Partitioner = sarama.NewRandomPartitioner
	//cfg.Producer.Partitioner = sarama.NewManualPartitioner

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
