use std::env;
use std::fs;

fn main() {
    let current_dir = env::current_dir() {
        Ok(path) => path,
        Err(e) => {
            eprintln!("Failed to get current directory: {}", e);
            return;
        }
    };

    let folders: Vec<String> = env::args().skip(1).collect();

    if folders.is_empty() {
        println!("Usages: mkfolders <folder1> <folder2> ...");
        return;
    }   

    println!("Creating folders in: {}", current_dir.display());

    for folder in folders {
        let path = current_dir.join(&folder);

        match fs::create_dir_all(&path) {
            Ok(_) => println!("Created folder: {}", path.display()),
            Err(error) => eprintln!("Failed to create folder {}: {}", path.display(), error),
        }
    }

}