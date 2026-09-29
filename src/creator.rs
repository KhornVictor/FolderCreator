use std::fs;
use std::path::{Path, PathBuf};
use std::thread;
use std::time::Duration;

use colored::Colorize;
use indicatif::{ProgressBar, ProgressStyle};

pub struct CreationSummary {
    pub created: Vec<PathBuf>,
    pub existed: Vec<PathBuf>,
    pub failed: Vec<(PathBuf, String)>,
}

pub fn sanitize_folder_list(folders: &[String]) -> Vec<String> {
    let mut cleaned = Vec::new();

    for raw in folders {
        let normalized = raw.replace('\\', "/");
        let parts: Vec<&str> = normalized
            .split('/')
            .map(|s| s.trim())
            .filter(|s| !s.is_empty())
            .collect();

        if parts.is_empty() {
            continue;
        }

        // Filter illegal characters in Windows folder names: < > : " | ? *
        let valid_parts: Vec<String> = parts
            .into_iter()
            .map(|part| {
                part.chars()
                    .filter(|c| !['<', '>', ':', '"', '|', '?', '*'].contains(c))
                    .collect::<String>()
            })
            .filter(|p| !p.is_empty())
            .collect();

        if !valid_parts.is_empty() {
            let path_str = valid_parts.join("/");
            if !cleaned.contains(&path_str) {
                cleaned.push(path_str);
            }
        }
    }

    cleaned
}

pub fn execute_folder_creation(base_dir: &Path, folders: &[String]) -> CreationSummary {
    let mut created = Vec::new();
    let mut existed = Vec::new();
    let mut failed = Vec::new();

    println!("{}", "🚀 Creating folders...".bold().cyan());

    let pb = ProgressBar::new(folders.len() as u64);
    pb.set_style(
        ProgressStyle::default_bar()
            .template("{spinner:.green} [{elapsed_precise}] [{bar:30.cyan/blue}] {pos}/{len} {msg}")
            .unwrap_or_else(|_| ProgressStyle::default_bar())
            .progress_chars("█▓▒░"),
    );

    for folder in folders {
        let path = base_dir.join(folder);
        pb.set_message(format!("Processing {}", folder));

        if path.exists() {
            if path.is_dir() {
                existed.push(path);
            } else {
                failed.push((path, "Path exists but is a file".to_string()));
            }
        } else {
            match fs::create_dir_all(&path) {
                Ok(_) => created.push(path),
                Err(e) => failed.push((path, e.to_string())),
            }
        }

        pb.inc(1);
        thread::sleep(Duration::from_millis(25));
    }

    pb.finish_with_message("Done!");
    println!();

    CreationSummary {
        created,
        existed,
        failed,
    }
}
