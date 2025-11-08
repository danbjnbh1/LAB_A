all: build main my_echo encoder

# Create build directory
build:
	mkdir -p build

# Link main executable (in root)
main: build/main.o build/numbers.o build/add.o
	gcc -g -m32 -Wall -o main build/main.o build/numbers.o build/add.o

# Link my_echo executable (in root)
my_echo: build/my_echo.o
	gcc -g -m32 -Wall -o my_echo build/my_echo.o

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
	rm -rf build main my_echo encoder

.PHONY: all clean