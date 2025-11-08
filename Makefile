all: bin build bin/main bin/my_echo encoder

# Create bin directory
bin:
	mkdir -p bin

# Create build directory
build:
	mkdir -p build

# Link main executable to bin/
bin/main: build/main.o build/numbers.o build/add.o
	gcc -g -m32 -Wall -o bin/main build/main.o build/numbers.o build/add.o

# Link my_echo executable to bin/
bin/my_echo: build/my_echo.o
	gcc -g -m32 -Wall -o bin/my_echo build/my_echo.o

# Link encoder executable (in root)
encoder: build/encoder.o
	gcc -g -m32 -Wall -o encoder build/encoder.o

# Compile C files to build directory
build/main.o: main.c
	gcc -g -m32 -Wall -c main.c -o build/main.o

build/numbers.o: numbers.c
	gcc -g -m32 -Wall -c numbers.c -o build/numbers.o

build/my_echo.o: my_echo.c
	gcc -g -m32 -Wall -c my_echo.c -o build/my_echo.o

build/encoder.o: encoder.c
	gcc -g -m32 -Wall -c encoder.c -o build/encoder.o

# Assemble assembly file to build directory
build/add.o: add.s
	nasm -g -f elf -w+all -o build/add.o add.s

clean:
	rm -rf build bin encoder

.PHONY: all clean