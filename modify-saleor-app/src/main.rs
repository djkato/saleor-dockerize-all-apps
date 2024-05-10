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

    let mut output = fs::read_to_string("./changes/snippets/import_redisapl.ts")?;
    for line in file.as_mut().lines() {
        output.push_str(&(line.to_owned() + "\n"));
        if line.contains("switch") {
            let case = fs::read_to_string("./changes/snippets/case_redisapl.ts")?;
            output.push_str(&case);
        }
    }
    fs::write(&args[1], output)?;

    Ok(())
}

// use std::{
//     io,
//     path::{Path, PathBuf},
//     process::Command,
//     str::FromStr,
// };
//
// use serde::{Deserialize, Serialize};
// use walkdir::WalkDir;
//
// fn main() -> Result<(), io::Error> {
//     let snippets = get_snippets().unwrap();
//     let actions = get_actions().unwrap();
//     let changes = get_changes()
//         .unwrap()
//         .into_iter()
//         .map(|c| Box::new(c))
//         .collect::<Vec<_>>();
//
//     for change in changes {
//         let mut current_cumulative_path = std::env::current_dir()?;
//         current_cumulative_path.push("all_apps");
//         current_cumulative_path.push(&change.folder);
//
//         process_change(&change, &current_cumulative_path);
//         if let Some(sub) = change.sub {
//             iter_sub(sub)
//         }
//     }
//
//     Ok(())
// }
// pub fn process_change(
//     change: &Box<Change>,
//     current_cumulative_path: &PathBuf,
// ) -> Result<(), io::Error> {
//     if let Some(actions) = &change.actions {
//         for action in actions {
//             let mut current_file = current_cumulative_path.clone();
//             current_file.push(&action.target);
//             let command;
//             match action.action_type {
//                 ActionType::Create => Command::new("ln").args(["-s", current_file]),
//                 ActionType::Insert => {}
//             }
//         }
//     }
//     Ok(())
// }
//
// pub fn iter_sub(sub: Vec<Box<Change>>) {
//     for change in sub {
//         process_change(&change);
//         if let Some(further_sub) = change.sub {
//             iter_sub(further_sub)
//         }
//     }
// }
//
// pub fn get_changes() -> Result<Vec<Change>, std::io::Error> {
//     Ok(serde_json::from_str(&std::fs::read_to_string(
//         "./changes/changes.json",
//     )?)?)
// }
//
// pub fn get_snippets() -> Result<Vec<Snippet>, std::io::Error> {
//     let mut snippets = vec![];
//     for entry in WalkDir::new("./changes/snippets").into_iter().flatten() {
//         if entry.path().is_file() {
//             if let Some(name) = entry.path().file_stem() {
//                 if let Some(name) = name.to_str() {
//                     snippets.push(Snippet {
//                         id: SnippetId(name.to_owned()),
//                         value: std::fs::read_to_string(entry.path())?,
//                     })
//                 }
//             };
//         }
//     }
//     Ok(snippets)
// }
//
// pub fn get_actions() -> Result<Vec<NamedActions>, std::io::Error> {
//     Ok(serde_json::from_str(&std::fs::read_to_string(
//         "./changes/actions.json",
//     )?)?)
// }
//
// #[derive(Serialize, Deserialize, Debug)]
// pub struct Change {
//     pub folder: String,
//     pub sub: Option<Vec<Box<Self>>>,
//     pub actions_by_ref: Option<Vec<ActionsId>>,
//     pub actions: Option<Vec<Action>>,
// }
//
// #[derive(Serialize, Deserialize, Debug)]
// pub struct NamedActions {
//     pub name: ActionsId,
//     pub actions: Vec<Action>,
// }
//
// #[derive(Serialize, Deserialize, Debug)]
// pub struct Action {
//     pub target: String,
//     pub action_type: ActionType,
//     pub snippets: Vec<ActionStep>,
// }
//
// #[derive(Serialize, Deserialize, Debug)]
// pub struct ActionStep {
//     pub after: Option<String>,
//     pub snippet: SnippetId,
// }
//
// #[derive(Serialize, Deserialize, Debug)]
// pub struct Snippet {
//     id: SnippetId,
//     value: String,
// }
//
// #[derive(Serialize, Deserialize, Debug)]
// pub enum ActionType {
//     Insert,
//     Create,
// }
//
// #[derive(Serialize, Deserialize, Debug, PartialEq)]
// #[serde(transparent)]
// pub struct SnippetId(pub String);
//
// #[derive(Serialize, Deserialize, Debug, PartialEq)]
// #[serde(transparent)]
// pub struct ActionsId(pub String);
