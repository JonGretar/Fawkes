# Fawkes

Fawkes is a command-line tool designed to enhance Elixir development workflows. It provides a set of utilities to help you navigate, manipulate, and generate code more efficiently.

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

## Configuration

Fawkes can be configured through a JSON configuration file. The tool looks for configuration in the following locations (in order of precedence):

1. `./.fawkes.json` (current directory)
2. `~/.fawkes.json` (home directory)
3. `~/.config/fawkes/config.json` (XDG config directory)

Example configuration file:

```json
{
  "fileExtensions": {
    "source": "ex",
    "test": "exs"
  },
  "pathFormats": {
    "lib": "lib",
    "test": "test",
    "web": "_web",
    "controllers": "controllers",
    "views": "views",
    "live": "live",
    "templates": "templates",
    "components": "components",
    "channels": "channels",
    "tasks": "tasks",
    "features": "features"
  },
  "templates": {
    "moduleSuffix": true,
    "includeUse": true,
    "includeModuleDoc": false
  },
  "editor": {
    "command": "code",
    "arguments": ["-g"]
  }
}
```

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

## Editor Integration

When using the `--open` flag, Fawkes will open the resulting file in an editor. The editor is determined in the following order:

1. Command-line option: `--editor vim`
2. Configuration file setting (`editor.command` and `editor.arguments`)
3. Environment variables: `$EDITOR` or `$VISUAL`
4. Default: Visual Studio Code (`code -g`)

Example with different editors:
```bash
# Open with default editor (from config or environment)
fawkes alternate lib/my_app/user.ex --target test --open

# Open with specific editor
fawkes alternate lib/my_app/user.ex --target test --open --editor vim

# Convert, create if needed (with template), and open in editor
fawkes alternate lib/my_app/user.ex --target test --create --open

# Convert, create empty file without template, and open in editor
fawkes alternate lib/my_app/user.ex --target test --create --skip-template --open
```

This is particularly useful in editor-agnostic environments or when using terminal-based workflows.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by Jón Grétar Borgþórsson.