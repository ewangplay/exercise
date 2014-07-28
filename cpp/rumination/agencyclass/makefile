#makefile

TARGET=test
GCC=g++  
SRCS= $(wildcard ./*.cpp)
OBJS = $(SRCS:%.cpp=%.o)

all:$(TARGET)

$(TARGET):$(OBJS)  
	$(GCC) -o $(TARGET) $(OBJS)  

.PHONY : clean
clean:
	rm -f $(TARGET) $(OBJS)
