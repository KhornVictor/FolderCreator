mod cli;
mod creator;
mod interactive;
mod tree;
mod ui;

use std::env;

fn main() {
    #[cfg(windows)]
    colored::control::set_virtual_terminal(true).ok();

    ui::print_banner();

    let current_dir = env::current_dir().expect("Failed to get current directory");
    let args: Vec<String> = env::args().skip(1).collect();

    if !args.is_empty() {
        cli::handle_cli_args(&current_dir, &args);
    } else {
        interactive::run_interactive_mode(&current_dir);
    }
}