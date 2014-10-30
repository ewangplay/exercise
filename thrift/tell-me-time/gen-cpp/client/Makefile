CC=g++
CXXFLAGS=-I/usr/local/include/thrift -std=c++11

TARGET=client
OBJ=$(patsubst %.cpp,%.o,$(wildcard *.cpp))

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) -o $(TARGET) $(OBJ) -lthrift

clean:
	rm -f *.o client

