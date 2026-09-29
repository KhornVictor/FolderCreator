use std::path::Path;
use colored::Colorize;

use crate::creator::{execute_folder_creation, sanitize_folder_list};
use crate::tree::print_tree_preview;
use crate::ui::print_summary;

pub fn handle_cli_args(current_dir: &Path, args: &[String]) {
    if args.contains(&"-h".to_string()) || args.contains(&"--help".to_string()) {
        println!("{}", "USAGE:".yellow().bold());
        println!("  FolderCreator [OPTIONS] [FOLDERS...]");
        println!();
        println!("{}", "EXAMPLES:".yellow().bold());
        println!("  FolderCreator                       Launch interactive mode");
        println!("  FolderCreator src docs tests        Create 'src', 'docs', and 'tests'");
        println!("  FolderCreator api/v1 api/v2         Create nested folder trees");
        println!();
        println!("{}", "OPTIONS:".yellow().bold());
        println!("  -h, --help                          Show this help message and exit");
        return;
    }

    println!("{}", "⚡ Running in CLI Mode".bold().cyan());
    println!("📂 Target directory: {}", current_dir.display().to_string().bright_yellow().bold());
    println!();

    let sanitized = sanitize_folder_list(args);
    if sanitized.is_empty() {
        println!("{}", "⚠ No valid folder names provided.".yellow());
        return;
    }

    print_tree_preview(current_dir, &sanitized);
    let summary = execute_folder_creation(current_dir, &sanitized);
    print_summary(current_dir, &summary);
}
