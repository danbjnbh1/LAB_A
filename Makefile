# Build directory for object files
BUILD_DIR = build

all: $(BUILD_DIR) main my_echo encoder

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Link main executable (in root)
main: $(BUILD_DIR)/main.o $(BUILD_DIR)/numbers.o $(BUILD_DIR)/add.o
	gcc -g -m32 -Wall -o main $(BUILD_DIR)/main.o $(BUILD_DIR)/numbers.o $(BUILD_DIR)/add.o

# Link my_echo executable (in root)
my_echo: $(BUILD_DIR)/my_echo.o
	gcc -g -m32 -Wall -o my_echo $(BUILD_DIR)/my_echo.o

# Link encoder executable (in root)
encoder: $(BUILD_DIR)/encoder.o
	gcc -g -m32 -Wall -o encoder $(BUILD_DIR)/encoder.o

# Compile C files to build directory
$(BUILD_DIR)/main.o: main.c
	gcc -g -m32 -Wall -c main.c -o $(BUILD_DIR)/main.o

$(BUILD_DIR)/numbers.o: numbers.c
	gcc -g -m32 -Wall -c numbers.c -o $(BUILD_DIR)/numbers.o

$(BUILD_DIR)/my_echo.o: my_echo.c
	gcc -g -m32 -Wall -c my_echo.c -o $(BUILD_DIR)/my_echo.o

$(BUILD_DIR)/encoder.o: encoder.c
	gcc -g -m32 -Wall -c encoder.c -o $(BUILD_DIR)/encoder.o

# Assemble assembly file to build directory
$(BUILD_DIR)/add.o: add.s
	nasm -g -f elf -w+all -o $(BUILD_DIR)/add.o add.s

clean:
	rm -rf $(BUILD_DIR) main my_echo encoder

.PHONY: all clean