# Fawkes

Fawkes is a command-line tool designed to enhance Elixir development workflows with Zed editor integration. It provides a set of utilities to help you navigate, manipulate, and generate code more efficiently.

**This is just a proof of concept at this stage.** The alternative paths may not make sense at this point. I have not gone over this in a real project or tested this to any real extent. I know that a lot of things in it just do not make sense.

## Features

### Alternate Command

The `alternate` command (or its alias `alt`) helps you navigate between related files in an Elixir/Phoenix project, such as:

- Implementation and test files
- Models and controllers
- Controllers and views
- Controllers and HTML templates
- Controllers and JSON renderers
- Controllers and LiveView modules
- Components and component tests
- LiveView components
- Channels
- Mix tasks
- Feature tests

```
$ fawkes alternate lib/my_app/user.ex --target test
test/my_app/user_test.exs

$ fawkes alt lib/my_app_web/controllers/user_controller.ex --target view
lib/my_app_web/views/user_view.ex
```

## Installation

### From Source

1. Clone the repository:

   ```bash
   git clone https://github.com/JonGretar/fawkes.git
   cd fawkes
   ```

2. Build the project:

   ```bash
   swift build -c release
   ```

3. Install the binary:
   ```bash
   cp -f .build/release/fawkes /usr/local/bin/fawkes
   ```

## Usage

### Alternate Command

Convert between different types of files:

```
USAGE: fawkes alternate [--target <target>] <input-path> [--verbose] [--create] [--skip-template] [--open] [--editor <editor>] [--show-template]

ARGUMENTS:
  <input-path>            The input file path to convert

OPTIONS:
  --target <target>       Type of target to visit (default: test)
  --verbose               Show details about the conversion
  --create                Create the target file if it doesn't exist (with template by default)
  --skip-template         Skip template generation when creating files
  --open                  Open the resulting file in an editor
  --editor <editor>       Specify which editor to use (overrides config and environment)
  --show-template         Output the template that would be used to create the file
  -h, --help              Show help information
```

Available target types:

- `test`: Switch between implementation files and tests
- `controller`: Navigate to controller files
- `model`: Navigate to model files
- `view`: Navigate to view files
- `html`: Navigate to HTML templates
- `live`: Navigate to LiveView files
- `component`: Navigate to component files
- `liveComponent`: Navigate to LiveView component files
- `channel`: Navigate to channel files
- `json`: Navigate to JSON renderer files
- `task`: Navigate to Mix task files
- `feature`: Navigate to feature test files

## File Templates

When using the `--create` flag, Fawkes will automatically generate appropriate file templates based on the file type (unless `--skip-template` is specified):

### Controller Template

```elixir
defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller
end
```

### Model Template

```elixir
defmodule MyApp.User do
  use Ecto.Schema
  import Ecto.Changeset
end
```

### LiveView Template

```elixir
defmodule MyAppWeb.UserLive do
  use MyAppWeb, :live_view
end
```

Templates are customizable through the configuration file.

## Zed Editor Integration

Fawkes is designed to work seamlessly with the Zed editor. When using the `--open` flag, Fawkes will open the resulting file directly in Zed by default.

### Task Configuration

Create a `.zed/tasks.json` file in your project root with the following tasks:

```json
[
  {
    "label": "Fawkes: Go to test",
    "command": "fawkes alternate --target test --open --editor zed $ZED_FILE",
    "reveal": "never",
    "hide": "always",
    "tags": ["fawkes-alternate"]
  },
  {
    "label": "Fawkes: Choose alternate target",
    "command": "fawkes alternate --open --editor zed $ZED_FILE",
    "reveal": "always",
    "hide": "always",
    "tags": ["fawkes-choose"]
  },
  {
    "label": "Fawkes: Choose alternate target and create if missing",
    "command": "fawkes alternate --create --open --editor zed $ZED_FILE",
    "reveal": "always",
    "hide": "always",
    "tags": ["fawkes-create"]
  }
]
```

### Keybindings

Add the following to your `keymap.json` file (accessible via `zed: open keymap` command):

```json
{
  "context": "Editor && (extension==ex || extension==exs)",
  "bindings": {
    "alt-t": ["task::Spawn", { "task_name": "Fawkes: Go to test" }],
    "alt-a": [
      "task::Spawn",
      {
        "task_name": "Fawkes: Choose alternate target",
        "reveal_target": "center"
      }
    ],
    "alt-shift-a": [
      "task::Spawn",
      {
        "task_name": "Fawkes: Choose alternate target and create if missing",
        "reveal_target": "center"
      }
    ]
  }
}
```

### Usage

With these configurations, you can use the following keyboard shortcuts:

- `Alt+T`: Directly navigate to the test file for the current file
- `Alt+A`: Choose an alternate target for the current file (only showing existing files)
- `Alt+Shift+A`: Choose an alternate target for the current file (with option to create new files)

### Additional Tasks

Here are some additional task examples for common Fawkes operations:

```json
[
  {
    "label": "Fawkes: Go to controller",
    "command": "fawkes alternate --target controller --open --editor zed $ZED_FILE",
    "hide": "always",
    "reveal": "always"
  },
  {
    "label": "Fawkes: Go to model",
    "command": "fawkes alternate --target model --open --editor zed $ZED_FILE",
    "hide": "always",
    "reveal": "always"
  },
  {
    "label": "Fawkes: Go to view",
    "command": "fawkes alternate --target view --open --editor zed $ZED_FILE",
    "hide": "always",
    "reveal": "always"
  }
]
```

### Other Editors

While Zed is the default, you can specify a different editor using the `--editor` flag:

```bash
# Open with specific editor
fawkes alternate lib/my_app/user.ex --target test --open --editor vim
```

## Interactive Target Selection

When running `fawkes alternate` without specifying a target, an interactive menu will be displayed allowing you to:

1. Navigate through targets using arrow keys or j/k
2. Select a target with Enter/Space
3. Use number keys (1-9) as shortcuts
4. Cancel with Escape

The menu will also indicate which files will need to be created:

```
Available targets for lib/my_app/user.ex:
 → test
   controller (create new)
   model
   view (create new)
   html (create new)
   live (create new)
```

Navigate: ↑/↓ or j/k | Select: Enter/Space | Cancel: Esc | Shortcut: 1-9

```

## Example Files

This repository includes ready-to-use example files in the `docs/zed/examples` directory:

- `tasks.json`: A comprehensive set of Fawkes tasks for Zed (all configured to open files directly in Zed)
- `keymap.json`: Corresponding keybindings for these tasks

To use these files:

1. Create a `.zed` directory in your project root
2. Copy `examples/tasks.json` to `.zed/tasks.json`
3. Add the keybindings from `examples/keymap.json` to your global keymap or create a project-specific keymap

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by Jón Grétar Borgþórsson.
```
