use std::path::Path;
use std::process::Command;

use colored::Colorize;

use crate::creator::CreationSummary;

pub fn print_banner() {
    println!("{}", "╔═════════════════════════════════════════════════════════════╗".cyan());
    println!("{}", "║                    📁 FOLDER CREATOR                        ║".bold().cyan());
    println!("{}", "║          Fast, modern & interactive directory builder       ║".bright_white());
    println!("{}", "╚═════════════════════════════════════════════════════════════╝".cyan());
    println!();
}

pub fn print_summary(base_dir: &Path, summary: &CreationSummary) {
    println!("{}", "╔═════════════════════════════════════════════════════════════╗".green());
    println!("{}", "║                      CREATION SUMMARY                       ║".bold().green());
    println!("{}", "╚═════════════════════════════════════════════════════════════╝".green());

    println!("  📂 Target Directory: {}", base_dir.display().to_string().bright_yellow());
    println!(
        "  ✨ Newly Created:    {}",
        summary.created.len().to_string().bold().green()
    );
    println!(
        "  ℹ  Already Existed:  {}",
        summary.existed.len().to_string().bold().yellow()
    );
    println!(
        "  ✖  Failed:           {}",
        summary.failed.len().to_string().bold().red()
    );
    println!();

    if !summary.created.is_empty() {
        println!("{}", "  Created Folders:".green().bold());
        for p in summary.created.iter().take(10) {
            let rel = p.strip_prefix(base_dir).unwrap_or(p);
            println!("    {} {}", "✓".green(), rel.display());
        }
        if summary.created.len() > 10 {
            println!("    ... and {} more", summary.created.len() - 10);
        }
        println!();
    }

    if !summary.existed.is_empty() {
        println!("{}", "  Already Existed:".yellow().bold());
        for p in summary.existed.iter().take(5) {
            let rel = p.strip_prefix(base_dir).unwrap_or(p);
            println!("    {} {}", "ℹ".yellow(), rel.display());
        }
        if summary.existed.len() > 5 {
            println!("    ... and {} more", summary.existed.len() - 5);
        }
        println!();
    }

    if !summary.failed.is_empty() {
        println!("{}", "  Errors:".red().bold());
        for (path, err) in &summary.failed {
            println!("    ✖ {}: {}", path.display(), err);
        }
        println!();
    }
}

pub fn open_in_explorer(dir: &Path) {
    let _ = Command::new("explorer").arg(dir).spawn();
    println!("🚀 Opened Windows File Explorer at {}", dir.display().to_string().cyan());
}
