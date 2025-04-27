# Sudoku Solver

A GTK4-based Sudoku puzzle solver application written in Vala. This application allows you to input Sudoku puzzles manually or load them from a file, and solves them using a backtracking algorithm.

## Features

- Clean and intuitive GTK4 user interface
- 9x9 grid for puzzle input
- Load random puzzles from a file
- Solve puzzles automatically
- Progress bar showing solving progress
- Menu system with New, Load Puzzle, and Quit options
- Visual feedback for edited and loaded cells

## Requirements

- Vala compiler
- GTK 4.0
- GLib 2.0
- Meson (for building)

## Building

To build the application, run:

```bash
meson build
cd build
ninja
```

## Usage

1. Run the application:
```bash
./sudoku
```

2. You can:
   - Enter numbers manually in the grid
   - Click "Load Puzzle" to load a random puzzle from problems.csv
   - Click "Solve" to solve the current puzzle
   - Click "New" to clear the grid

## File Format

The program expects puzzles to be stored in a `problems.csv` file, with each line containing 81 characters representing a puzzle. Use:
- Numbers 1-9 for given numbers
- 0 for empty cells

Example:
```
530070000600195000098000060800060003400803001700020006060000280000419005000080079
```

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.