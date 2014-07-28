#makefile for helloworld

TARGET=lifepad
SRCS=$(wildcard ./*.c)
OBJS=$(SRCS:%.c=%.o)
CC=gcc
CFLAGS+=`pkg-config --cflags gtk+-2.0`
LIBS=`pkg-config --libs gtk+-2.0`


all:$(TARGET)

$(TARGET):$(OBJS)
	$(CC) -o $(TARGET) $(OBJS) $(LIBS)

.PHONY:clean

clean:
	rm -f $(TARGET) $(OBJS)
