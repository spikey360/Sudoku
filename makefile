# Compiler and flags
VALAC = valac
PKGS = --pkg gtk4 --pkg gio-2.0
SRC = sudoku.vala
OUT = sudoku

# Default target
all: $(OUT)

# Build the executable
$(OUT): $(SRC)
	$(VALAC) $(PKGS) -o $(OUT) $(SRC)

# Clean up generated files
clean:
	rm -f $(OUT)