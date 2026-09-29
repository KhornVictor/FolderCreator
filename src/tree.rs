use std::collections::BTreeMap;
use std::path::Path;
use colored::Colorize;

#[derive(Default)]
pub struct TreeNode {
    pub children: BTreeMap<String, TreeNode>,
}

impl TreeNode {
    pub fn insert(&mut self, path: &str) {
        let clean = path.replace('\\', "/");
        let parts: Vec<&str> = clean
            .split('/')
            .map(|s| s.trim())
            .filter(|s| !s.is_empty())
            .collect();

        let mut current = self;
        for part in parts {
            current = current.children.entry(part.to_string()).or_default();
        }
    }

    pub fn render_children(&self, prefix: &str) -> Vec<String> {
        let mut lines = Vec::new();
        let total = self.children.len();

        for (i, (name, child)) in self.children.iter().enumerate() {
            let is_last = i + 1 == total;
            let branch = if is_last { "└── " } else { "├── " };
            let icon = "📁";
            lines.push(format!(
                "{}{}{} {}",
                prefix.dimmed(),
                branch.cyan(),
                icon,
                name.bold().bright_white()
            ));

            let next_prefix = format!("{}{}", prefix, if is_last { "    " } else { "│   " });
            lines.extend(child.render_children(&next_prefix));
        }

        lines
    }
}

pub fn print_tree_preview(base_dir: &Path, folders: &[String]) {
    println!();
    println!("{}", "┌─────────────────────────────────────────────────────────────┐".cyan());
    println!("{}", "│                    STRUCTURE PREVIEW                        │".bold().cyan());
    println!("{}", "└─────────────────────────────────────────────────────────────┘".cyan());
    println!("📂 Base: {}", base_dir.display().to_string().bold().bright_yellow());
    println!();

    let mut root = TreeNode::default();
    for folder in folders {
        root.insert(folder);
    }

    let lines = root.render_children("");
    for line in lines {
        println!("{}", line);
    }
    println!();
    println!("📊 Total folders to create: {}", folders.len().to_string().bold().bright_green());
    println!();
}
