use std::path::Path;

use colored::Colorize;
use inquire::{Confirm, InquireError, Text};

use crate::creator::{execute_folder_creation, sanitize_folder_list};
use crate::tree::print_tree_preview;
use crate::ui::{open_in_explorer, print_summary};

pub fn run_interactive_mode(current_dir: &Path) {
    println!("{}", "⚡ Interactive Mode".bold().cyan());
    println!("📂 Target directory: {}", current_dir.display().to_string().bright_yellow().bold());
    println!("{}", "Enter folder names one by one (type 'q' or press Enter to auto-create):".dimmed());
    println!();

    let mut folders = Vec::new();
    let mut index = 1;

    loop {
        let prompt_text = format!("Folder #{}:", index);
        let input = match Text::new(&prompt_text).prompt() {
            Ok(val) => val,
            Err(InquireError::OperationCanceled | InquireError::OperationInterrupted) => {
                println!("\n{}", "👋 Canceled. Exiting.".yellow());
                return;
            }
            Err(e) => {
                eprintln!("{}: {}", "Error reading input".red(), e);
                return;
            }
        };

        let trimmed = input.trim();

        // When input = q or empty line, stop collecting and auto-create
        if trimmed.is_empty() || trimmed.eq_ignore_ascii_case("q") {
            break;
        }

        folders.push(trimmed.to_string());
        println!("  {} Added '{}' (Total: {})", "✓".green(), trimmed.bold(), folders.len());
        index += 1;
    }

    if folders.is_empty() {
        println!("{}", "No folders specified. Exiting.".yellow());
        return;
    }

    let sanitized = sanitize_folder_list(&folders);
    if sanitized.is_empty() {
        println!("{}", "⚠ No valid folder names specified. Exiting.".yellow());
        return;
    }

    // Auto-create folders immediately upon 'q'
    print_tree_preview(current_dir, &sanitized);
    let summary = execute_folder_creation(current_dir, &sanitized);
    print_summary(current_dir, &summary);

    let open_explorer = Confirm::new("Open target folder in Windows File Explorer?")
        .with_default(false)
        .prompt()
        .unwrap_or(false);

    if open_explorer {
        open_in_explorer(current_dir);
    }

    println!("{}", "👋 All done!".green().bold());
}
