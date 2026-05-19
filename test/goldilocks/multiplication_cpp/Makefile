CC=g++
CFLAGS=-std=c++11 -O3 -I.
DEPS_HPP = circom.hpp calcwit.hpp fr.hpp
DEPS_O = main.o calcwit.o

all: multiplication

%.o: %.cpp $(DEPS_HPP)
	$(CC) -c $< $(CFLAGS)

multiplication: $(DEPS_O) multiplication.o
	$(CC) -o multiplication *.o -lgmp 
