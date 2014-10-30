package main
import (
    "fmt"
    "time"
    "git.apache.org/thrift.git/lib/go/thrift"
    "TellMeTime"
)
func handleClient(client *TellMeTime.TimeServiceClient) (err error) {
    t,_ := client.TellMeTime()
    fmt.Println(time.Unix(int64(t), 0).String())
    return nil
}
func runClient(transportFactory thrift.TTransportFactory, protocolFactory thrift.TProtocolFactory, addr string) error {
    var transport thrift.TTransport
    transport, err := thrift.NewTSocket(addr)
    if err != nil {
        fmt.Println("Error opening socket:", err)
        return err
    }
    transport = transportFactory.GetTransport(transport)
    defer transport.Close()
    if err := transport.Open(); err != nil {
        return err
    }
    return handleClient(TellMeTime.NewTimeServiceClientFactory(transport, protocolFactory))
}
func main() {
    var protocolFactory thrift.TProtocolFactory
    protocolFactory = thrift.NewTBinaryProtocolFactoryDefault()
    var transportFactory thrift.TTransportFactory
    transportFactory = thrift.NewTBufferedTransportFactory(1024)
    addr := "localhost:9090"
    if err := runClient(transportFactory, protocolFactory, addr); err != nil {
        fmt.Println("error running client:", err)
    }
}
