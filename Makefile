all: build bin encoder bin/main bin/my_echo

build:
	mkdir -p build

bin:
	mkdir -p bin

encoder: build/encoder.o
	gcc -g -m32 -Wall -o encoder build/encoder.o

build/encoder.o: encoder.c build
	gcc -g -m32 -Wall -c encoder.c -o build/encoder.o

bin/main: build/main.o build/numbers.o build/add.o bin
	gcc -g -m32 -Wall -o bin/main build/main.o build/numbers.o build/add.o

build/main.o: main.c build
	gcc -g -m32 -Wall -c main.c -o build/main.o

build/numbers.o: numbers.c build
	gcc -g -m32 -Wall -c numbers.c -o build/numbers.o

build/add.o: add.s build
	nasm -g -f elf -w+all -o build/add.o add.s

bin/my_echo: build/my_echo.o bin
	gcc -g -m32 -Wall -o bin/my_echo build/my_echo.o

build/my_echo.o: my_echo.c build
	gcc -g -m32 -Wall -c my_echo.c -o build/my_echo.o

clean:
	rm -rf build bin encoder

.PHONY: all clean build bin