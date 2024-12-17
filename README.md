# aider.nvim

A Neovim plugin for seamlessly integrating with aider (AI pair programming tool).

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'your-username/aider.nvim',
    config = function()
        require('aider-nvim').setup({
            -- Optional configuration
            terminal_height = 15, -- Height of the terminal split
            command = "aider",    -- Command to run
        })
    end
}
```

## Usage

The plugin provides a command `:Aider` that opens a terminal split and runs aider.

## Configuration

You can configure the plugin by passing options to the setup function:

```lua
require('aider-nvim').setup({
    terminal_height = 15, -- Height of the terminal split
    terminal_width = 80,  -- Width of the terminal split
    command = "aider"     -- Command to run
})
```

## Requirements

- Neovim >= 0.5.0
- aider installed and available in your PATH

## Commands

- `:Aider` - Opens a terminal split and runs aider
- `:AiderAddFile [files...]` - Adds files to aider (uses current buffer's file if no arguments provided)
- `:AiderDropFile` - Removes the current buffer's file from aider
