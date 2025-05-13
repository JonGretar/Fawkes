# Fawkes Integration in Zed Editor

This guide shows how to set up Zed tasks and keybindings for working efficiently with Fawkes, the Elixir development helper tool.

## Task Configuration

Create a `.zed/tasks.json` file in your project root with the following tasks. You can find complete example files in the `examples/` directory.

```json
[
  {
    "label": "Fawkes: Go to test",
    "command": "fawkes alternate --target test --open --editor zed $ZED_FILE",
    "reveal": "always",
    "tags": ["fawkes-alternate"]
  },
  {
    "label": "Fawkes: Choose alternate target",
    "command": "fawkes alternate --open --editor zed $ZED_FILE",
    "reveal": "always",
    "tags": ["fawkes-choose"]
  },
  {
    "label": "Fawkes: Choose alternate target and create if missing",
    "command": "fawkes alternate --create --open --editor zed $ZED_FILE",
    "reveal": "always",
    "tags": ["fawkes-create"]
  }
]
```

## Keybindings

Add the following to your `keymap.json` file (accessible via `zed: open keymap` command):

```json
{
  "context": "Editor",
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

See `examples/keymap.json` for a more complete set of keybindings.

## Usage

With these configurations, you can use the following keyboard shortcuts:

- `Alt+T`: Directly navigate to the test file for the current file
- `Alt+A`: Choose an alternate target for the current file (only showing existing files)
- `Alt+Shift+A`: Choose an alternate target for the current file (with option to create new files)

## Task Behaviors

1. **Go to test**: Directly jumps to the test file corresponding to your current file
2. **Choose alternate target**: Shows an interactive menu of existing alternate files to navigate to
3. **Choose alternate target and create**: Shows an interactive menu of all possible alternate files, with the option to create missing files

## Opening Files

All tasks are configured with the `--open --editor zed` flags, which means:

1. Files will automatically open in Zed after selection
2. You don't need to click on paths or manually open files
3. The terminal is used just to display the operation results

Each task is configured like this:

```json
{
  "label": "Fawkes: Go to test",
  "command": "fawkes alternate --target test --open --editor zed $ZED_FILE",
  "reveal": "always"
}
```

## Advanced Configuration

While our tasks specify the editor directly with `--editor zed`, you can also configure Fawkes globally to use Zed as its default editor:

### Fawkes Configuration for Zed

Create a configuration file in `~/.config/fawkes/config.json` with the following content:

```json
{
  "editor": {
    "command": "zed",
    "arguments": []
  }
}
```

With this configuration, you could simplify your tasks to just use the `--open` flag without specifying the editor:

```json
{
  "label": "Fawkes: Go to test",
  "command": "fawkes alternate --target test --open $ZED_FILE",
  "reveal": "always"
}
```

### Additional Task Examples

Here are some additional task examples for common Fawkes operations:

```json
[
  {
    "label": "Fawkes: Go to controller",
    "command": "fawkes alternate --target controller --open --editor zed $ZED_FILE",
    "reveal": "always"
  },
  {
    "label": "Fawkes: Go to model",
    "command": "fawkes alternate --target model --open --editor zed $ZED_FILE",
    "reveal": "always"
  },
  {
    "label": "Fawkes: Go to view",
    "command": "fawkes alternate --target view --open --editor zed $ZED_FILE",
    "reveal": "always"
  }
]
```

You can add these to your `.zed/tasks.json` file and create corresponding keybindings in your `keymap.json`.

## Example Files

For your convenience, this directory includes complete example files that you can use as a starting point:

- `examples/tasks.json`: A comprehensive set of Fawkes tasks for Zed (all configured to open files directly in Zed)
- `examples/keymap.json`: Corresponding keybindings for these tasks

To use these files:

1. Create a `.zed` directory in your project root
2. Copy `examples/tasks.json` to `.zed/tasks.json`
3. Add the keybindings from `examples/keymap.json` to your global keymap or create a project-specific keymap
