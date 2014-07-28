# Project: handler
# Makefile created by Dev-C++ 4.9.9.2

CPP  = g++.exe
CC   = gcc.exe
WINDRES = windres.exe
RES  = 
OBJ  = main.o point_handler.o $(RES)
LINKOBJ  = main.o point_handler.o $(RES)
LIBS =  -L"C:/Program Files/DEV-CPP/Lib" -L"D:/DevLib/SDL-1.2.13/lib"  
INCS =  -I"C:/Program Files/DEV-CPP/include" 
CXXINCS =  -I"C:/Program Files/DEV-CPP/lib/gcc/mingw32/3.4.2/include"  -I"C:/Program Files/DEV-CPP/include/c++/3.4.2/backward"  -I"C:/Program Files/DEV-CPP/include/c++/3.4.2/mingw32"  -I"C:/Program Files/DEV-CPP/include/c++/3.4.2"  -I"C:/Program Files/DEV-CPP/include"  -I"D:/DevLib/SDL-1.2.13/include"  -I"C:/Program Files/DEV-CPP/the-agency/boost_1_31_0" 
BIN  = handler.exe
CXXFLAGS = $(CXXINCS)  
CFLAGS = $(INCS)  
RM = rm -f

.PHONY: all all-before all-after clean clean-custom

all: all-before handler.exe all-after


clean: clean-custom
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CPP) $(LINKOBJ) -o "handler.exe" $(LIBS)

main.o: main.cpp
	$(CPP) -c main.cpp -o main.o $(CXXFLAGS)

point_handler.o: point_handler.cpp
	$(CPP) -c point_handler.cpp -o point_handler.o $(CXXFLAGS)
