use std::{
    fs::{self, read_to_string},
    io,
};

fn main() -> Result<(), io::Error> {
    let args: Vec<_> = std::env::args().collect();
    if args.len() < 2 {
        std::process::exit(1)
    }

    let mut file = read_to_string(&args[1])?;

    let mut output = fs::read_to_string("./changes/snippets/import-path-app-next.config.js")?;
    let mut is_done = false;
    for line in file.as_mut().lines() {
        output.push_str(&(line.to_owned() + "\n"));
        if is_done {
            continue;
        };
        if line.contains("const nextConfig") {
            let case = fs::read_to_string("./changes/snippets/apps-next.config.js")?;
            output.push_str(&case);
            is_done = true;
        }
    }
    fs::write(&args[1], output)?;

    Ok(())
}
