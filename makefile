# Compiler and flags
VALAC = valac
PKGS = --pkg gtk4 --pkg gio-2.0
SRC_FILES = $(SRC)/sudoku.vala
OUT = sudoku
BIN = ./bin
SRC = ./src

# Create bin directory if it doesn't exist
$(BIN):
	mkdir -p $(BIN)

# Default target
all: $(BIN) $(BIN)/$(OUT)

# Build the executable
$(BIN)/$(OUT): $(SRC_FILES)
	$(VALAC) $(PKGS) -o $(BIN)/$(OUT) $(SRC_FILES)

# Clean up generated files
clean:
	rm -rf $(BIN)