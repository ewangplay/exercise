#include "TimeService.h"
#include <thrift/transport/TSocket.h>
#include <thrift/transport/TBufferTransports.h>
#include <thrift/protocol/TBinaryProtocol.h>
#include <iostream>

using namespace std;
using namespace apache::thrift;
using namespace apache::thrift::protocol;
using namespace apache::thrift::transport;
using namespace jiuzhilan_time;

int main(int argc, char *argv[]) {
    boost::shared_ptr<TSocket> socket(new TSocket("localhost", 9090));
    boost::shared_ptr<TTransport> transport(new TBufferedTransport(socket));
    boost::shared_ptr<TProtocol> protocol(new TBinaryProtocol(transport));
    time_t mytime = 0;
    TimeServiceClient client(protocol);
    transport->open();
    mytime = client.TellMeTime();
    cout << "Now is " << ctime(&mytime) << endl;
    transport->close();
    return 0;
}
