using Gtk;
using GLib;

public class SudokuSolver : Gtk.Application {

private static int MAX_SUM = 1 ^ 2 ^ 3 ^ 4 ^ 5 ^ 6 ^ 7 ^ 8 ^ 9;
    public SudokuSolver(string runtime_path) {
        Object(application_id: "com.example.SudokuSolver",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Gtk.ApplicationWindow(this);
        window.title = "Sudoku Solver";
        window.default_width = 400;
        window.default_height = 400;
    
        // Create a Gio.Menu
    var menu = new GLib.Menu();
    menu.append("New", "app.new");
    menu.append("Load Puzzle", "app.load");
    menu.append("Quit", "app.quit");

    // Create a MenuButton
    var menu_button = new Gtk.MenuButton();
    var popover = new Gtk.PopoverMenu.from_model(menu);
    menu_button.set_popover(popover);
    menu_button.icon_name = "open-menu-symbolic";
    

        var grid = new Gtk.Grid();
        grid.margin_top = 10;
        grid.margin_bottom = 10;
        grid.margin_start = 10;
        grid.margin_end = 10;
        grid.row_spacing = 5;
        grid.column_spacing = 5;

        var entry_grid = new Gtk.Grid();
        entry_grid.row_spacing = 2;
        entry_grid.column_spacing = 2;

        var menu_grid = new Gtk.Grid();
        menu_grid.row_spacing = 2;
        menu_grid.column_spacing = 2;

// Create a CSS provider
        var css_provider = new Gtk.CssProvider();
        css_provider.load_from_data((uint8[])"
            .custom-entry {
                background-color:rgb(96, 183, 218); /* Light red background */
            }
            .random-entry {
                background-color:rgb(218, 96, 96); /* Light green background */
            }
        ");
// Apply the CSS provider to the Entry
Gtk.StyleContext.add_provider_for_display(
    Gdk.Display.get_default(),
    css_provider,
    Gtk.STYLE_PROVIDER_PRIORITY_USER
);


        // Create a 9x9 grid of entries for Sudoku input
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                var entry = new Gtk.Entry();
                entry.max_length = 1;
                entry.width_chars = 1;
                entry.halign = Gtk.Align.CENTER;
                entry.valign = Gtk.Align.CENTER;
                entry_grid.attach(entry, i, j, 1, 1);
            }
        }

        //Add menu_button to menu_grid
        menu_grid.attach(menu_button, 9, 1, 1, 1);

        var solve_button = new Gtk.Button.with_label("Solve");
        solve_button.clicked.connect(() => {
            // Disable the solve button
            solve_button.set_sensitive(false);

            // Create a 2D array to store the Sudoku grid values
            int[,] sudoku_grid = new int[9, 9];

            // Populate the Sudoku grid from the UI
            for (int i = 0; i < 9; i++) {
                for (int j = 0; j < 9; j++) {
                    var child = entry_grid.get_child_at(i, j);
                    var entry = child as Gtk.Entry;
                    if (entry != null) {
                        string boxtext = entry.text.strip();
                        sudoku_grid[i, j] = boxtext.length == 0 ? 0 : int.parse(boxtext);
                        if (boxtext.length == 0) {
                            // Set the background color to light green
                            entry.get_style_context().add_class("custom-entry");
                            }
                    }
                }
            }

            // Run the solver in a separate thread
            new Thread<void> ("SudokuSolverThread",() => {
                var result = solve(sudoku_grid);

                // Update the UI in the main thread
                GLib.Idle.add(() => {
                    if (result == null) {
                        print("Sudoku is not valid\n");
                    } else {
                        print("Sudoku is solved\n");
                        solve_button.set_sensitive(false);
                        // Update the UI with the solved grid
                        for (int i = 0; i < 9; i++) {
                            for (int j = 0; j < 9; j++) {
                                var child = entry_grid.get_child_at(i, j);
                                var entry = child as Gtk.Entry;
                                if (entry != null) {
                                    entry.text = result[i, j].to_string();
                                    entry.set_editable(false);
                                }
                            }
                        }
                    }

                    // Re-enable the solve button
                    solve_button.set_sensitive(true);

                    return false; // Remove the idle callback
                });
            });
        });

    // Function to clear the Sudoku grid
    void clear_sudoku_grid() {
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                var child = entry_grid.get_child_at(i, j);
                // Cast the child to Gtk.Entry and set its text
                var entry = child as Gtk.Entry;
                if (entry != null) {
                    entry.text = "";
                    entry.set_editable(true);
                    entry.get_style_context().remove_class("custom-entry");
                    entry.get_style_context().remove_class("random-entry");
                    // Re-enable the solve button
                    solve_button.set_sensitive(true);
                }
            }
        }
    }

    // Add actions to the application
    var new_action = new GLib.SimpleAction("new", null);
    new_action.activate.connect(() => {
        clear_sudoku_grid();
    });
    add_action(new_action);



    var quit_action = new GLib.SimpleAction("quit", null);
    quit_action.activate.connect(() => {
        this.quit();
    });
    add_action(quit_action);

    //Load a random puzzle from a file
    void load_random_puzzle() {
        // Clear the Sudoku grid
        clear_sudoku_grid();

        // Open the file
        File file = File.new_for_path("problems.csv");

        uint8[] contents_bytes;
        file.load_contents(null, out contents_bytes, null);
        string contents = (string)(new Bytes(contents_bytes).get_data());

        // Split the contents into lines
        var lines = contents.split("\n");

        //print the number of lines
        print("Number of lines: %d\n", lines.length);
        int random_index = GLib.Random.int_range(0, lines.length);
        var random_line = lines[random_index];
        //print the random line
        print("Random line: %s\n", random_line);
        var charIndex = 0;
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                var child = entry_grid.get_child_at(j, i);
                // Cast the child to Gtk.Entry and set its text
                var entry = child as Gtk.Entry;
                if (entry != null) {
                    //read the nth character of the random_line
                    entry.text = random_line.get_char(charIndex++).to_string();
                    if (entry.text != "0"){
                    entry.set_editable(false);
                    entry.get_style_context().add_class("random-entry");
                    } else {
                        entry.text = "";
                        entry.set_editable(true);
                        entry.get_style_context().remove_class("random-entry");
                    }
                }
            }
        }
    }
    var load_action = new GLib.SimpleAction("load", null);
    load_action.activate.connect(() => {
        load_random_puzzle();
    });
    add_action(load_action);

        grid.attach(menu_grid, 0, 0, 1, 1);
        grid.attach(entry_grid, 0, 1, 1, 1);
        grid.attach(solve_button, 0, 2, 1, 1);

        window.set_child(grid);
        window.set_resizable(false);
        window.present();
    }

    public static int main(string[] args) {
        var app = new SudokuSolver(args[0]);
        stdout.printf("Runtime path: %s\n", args[0]);
        return app.run(args);
    }

    private int[,] solve(int[,] grid) {
        int total_cells = 81;
        int processed_cells = 0;

        // Function to display progress
        void show_progress() {
            double progress = (double)processed_cells / total_cells;
            int bar_width = 50;
            int pos = (int)(bar_width * progress);
            stdout.printf("\r[");
            for (int i = 0; i < bar_width; i++) {
                if (i < pos) stdout.printf("=");
                else if (i == pos) stdout.printf(">");
                else stdout.printf(" ");
            }
            stdout.printf("] %d%%", (int)(progress * 100));
            stdout.flush();
        }

        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                processed_cells++;
                show_progress();

                if (grid[i, j] == 0) {
                    // Check the possibilities for this cell
                    for (int u = 1; u <= 9; u++) {
                        bool found = false;
                        // Check if u is in the same row
                        for (int k = 0; k < 9; k++) {
                            if (grid[i, k] == u) {
                                found = true;
                                break;
                            }
                        }
                        // Check if u is in the same column
                        for (int k = 0; k < 9; k++) {
                            if (grid[k, j] == u) {
                                found = true;
                                break;
                            }
                        }
                        // Check if u is in the same square
                        int square_row = i / 3 * 3;
                        int square_col = j / 3 * 3;
                        for (int k = square_row; k < square_row + 3; k++) {
                            for (int l = square_col; l < square_col + 3; l++) {
                                if (grid[k, l] == u) {
                                    found = true;
                                    break;
                                }
                            }
                        }
                        // If u is not found in row, column or square, set it as a possibility
                        if (!found) {
                            // Set the cell to u and continue solving
                            grid[i, j] = u;
                            // Call the solve function recursively
                            int[,] result = solve(grid);
                            if (result != null) {
                                return result;
                            }
                            // If no solution found, reset the cell
                            grid[i, j] = 0;
                        }
                    }
                    return null; // Return null if no valid number can be placed
                }
            }
        }

        stdout.printf("\n"); // Finish the progress bar

        // check if all the numbers are in range 1-9
        if (!check_range(grid)) {
            //print("Out of range 1-9\n");
            return null;
        }
        // check if each row, column and square has all the numbers
        for (int i = 0; i < 9; i++) {
            if (!check_row(grid, i)) {
                //print("Row %d is not valid\n", i);
                return null;
            }
            if (!check_column(grid, i)) {
                //print("Column %d is not valid\n", i);
                return null;
            }
        }
        for (int i = 0; i < 9; i += 3) {
            for (int j = 0; j < 9; j += 3) {
                if (!check_square(grid, i, j)) {
                    //print("Square (%d, %d) is not valid\n", i, j);
                    return null;
                }
            }
        }
        // For now, just return the original grid
        return grid;
    }

    private bool check_range(int[,] grid) {
        // Check if the grid is a valid Sudoku solution
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                if (grid[i, j] < 0 || grid[i, j] > 9) {
                    return false;
                }
            }
        }
        return true;
    }
    private bool check_row(int[,] grid, int row) {
        int sum = 0;
        for (int i = 0; i < 9; i++) {
         sum ^= grid[row, i];
        }
        if (sum != MAX_SUM) {
            return false;
        }
        
        return true;
    }
private bool check_column(int[,] grid, int column) {
        int sum = 0;
        for (int i = 0; i < 9; i++) {
            sum ^= grid[i, column];
        }
        if (sum != MAX_SUM) {
            return false;
        }
        
        return true;
    }

    private bool check_square(int[,] grid, int row, int column) {
        int sum = 0;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                sum ^= grid[row + i, column + j];
            }
        }
        if (sum != MAX_SUM) {
            return false;
        }
        
        return true;
    }
}
