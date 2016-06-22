package main

import (
	"fmt"
	"github.com/Shopify/sarama"
	"os"
	"sync"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Printf("usage: %v <10.254.34.40:9092> <topic>\n", os.Args[0])
		os.Exit(1)
	}

	netAddr := os.Args[1]
	topicMonitor := os.Args[2]

	wg := &sync.WaitGroup{}
	cfg := sarama.NewConfig()

	c, err := sarama.NewConsumer([]string{netAddr}, cfg)
	if err != nil {
		fmt.Printf("new coustomer fail. %v\n", err)
		os.Exit(1)
	}

	topics, err := c.Topics()
	if err != nil {
		fmt.Printf("get topics fail. %v\n", err)
		goto END
	}

	for _, topic := range topics {
		fmt.Printf("Iterating Topic: %v\n", topic)

		if topic != topicMonitor {
			continue
		}
		fmt.Printf("Matched Topic: %v\n", topic)

		partitions, err := c.Partitions(topic)
		if err != nil {
			fmt.Printf("get partitions fail. %v\n", err)
			goto END
		}

		for _, partition := range partitions {
			fmt.Printf("Iterating partition: %v\n", partition)
			wg.Add(1)

			go func(topic string, partition int32, offset int64) error {
				defer wg.Done()

				pc, err := c.ConsumePartition(topic, partition, offset)
				if err != nil {
					fmt.Printf("get consumer partitions fail. %v\n", err)
					return err
				}
				defer pc.Close()

				chMessage := pc.Messages()
				chError := pc.Errors()

				for {
					select {
					case msg := <-chMessage:
						fmt.Printf("Topic: %v, Partitions: %v, Offset: %v, Key: %v, Value: %v\n", msg.Topic, msg.Partition, msg.Offset, string(msg.Key), string(msg.Value))
					case <-chError:
						break
					}
				}

				return nil
			}(topic, partition, sarama.OffsetOldest)
			//}(topic, partition, sarama.OffsetNewest)
		}
	}

END:
	wg.Wait()
	c.Close()
}
