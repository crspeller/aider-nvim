--- aider.nvim - A Neovim plugin for seamless integration with aider
--- @module aider-nvim
local M = {}

-- Default configuration
local default_config = {
    --- @type number Height of the terminal split in rows
    --- @type string Command to run for aider
    -- Default height of the terminal split (in rows)
    terminal_height = 15,
    -- Command to run
    command = "aider",
}

M.config = default_config

-- Track if plugin has been initialized
M.initialized = false

-- Function to setup the plugin with user config
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    M.initialized = true
end

-- Function to open aider in a terminal
function M.open_aider()
    -- Create a new split at the bottom
    vim.cmd(string.format("botright %dnew", M.config.terminal_height))
    
    -- Set buffer options for terminal
    vim.bo.buftype = "nofile"
    vim.bo.buflisted = false
    
    -- Open terminal with aider
    vim.fn.termopen(M.config.command, {
        on_exit = function()
            -- Close the window when aider exits
            vim.cmd("quit")
        end
    })
    
    -- Enter insert mode automatically
    vim.cmd("startinsert")
end

-- Create user command
vim.api.nvim_create_user_command("Aider", function()
    M.open_aider()
end, {})

return M
