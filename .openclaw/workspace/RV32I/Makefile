# RV32I UART16550 Controller Makefile
# C++17 or later required

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Werror -pedantic -O2 -I./include
LDFLAGS =

# Directories
SRC_DIR = src
TEST_DIR = tests
INCLUDE_DIR = include
BUILD_DIR = build

# Test target
TEST_TARGET = $(BUILD_DIR)/test_uart
TEST_SRC = $(TEST_DIR)/test_uart.cpp

.PHONY: all clean test dirs

all: dirs $(TEST_TARGET)

dirs:
	@mkdir -p $(BUILD_DIR)

$(TEST_TARGET): $(TEST_SRC)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

test: $(TEST_TARGET)
	@echo "Running UART16550 tests..."
	@./$(TEST_TARGET)

clean:
	rm -rf $(BUILD_DIR)

# Debug build
debug: CXXFLAGS += -g -DDEBUG -fsanitize=address,undefined
debug: LDFLAGS += -fsanitize=address,undefined
debug: clean all

# Help
help:
	@echo "RV32I UART16550 Controller Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all    - Build test executable (default)"
	@echo "  test   - Build and run tests"
	@echo "  clean  - Remove build artifacts"
	@echo "  debug  - Build with debug symbols and sanitizers"
	@echo "  help   - Show this help message"
