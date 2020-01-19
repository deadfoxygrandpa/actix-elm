use std::process::Command;
use std::env;
use std::fs;

fn main() {
    let out_dir = env::var("OUT_DIR").unwrap();

    let index = format!("{}/index.html", out_dir);

    let output = format!("--output={}", index);

    Command::new("elm").args(&["make", "frontend/Main.elm", "--optimize", &output])
        .status().unwrap();

    println!("compiled the elm frontend to {}", out_dir);

    fs::copy(&index, "static/index.html").unwrap();

    println!("copied elm code to static/");
}
