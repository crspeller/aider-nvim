--- aider.nvim - A Neovim plugin for seamless integration with aider
--- @module aider-nvim
local M = {}

-- Store terminal job and buffer
M.term_job = nil
M.term_buf = nil

-- Default configuration
local default_config = {
    --- @type number Height of the terminal split in rows
    --- @type number Width of the terminal split in columns
    --- @type string Command to run for aider
    -- Default height of the terminal split (in rows)
    terminal_height = 15,
    -- Default width of the terminal split (in columns)
    terminal_width = 80,
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
    -- Get window dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local is_wide = width > height * 2  -- Use 2:1 ratio as threshold

    local split_cmd = is_wide
        and string.format("vertical topleft %dnew", M.config.terminal_width)
        or string.format("botright %dnew", M.config.terminal_height)

    if M.term_job and vim.fn.jobwait({M.term_job}, 0)[1] == -1 then
        -- Aider is already running
        if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
            -- Check if buffer is already visible in a window
            local wins = vim.fn.win_findbuf(M.term_buf)
            if #wins > 0 then
                -- Jump to existing window
                vim.api.nvim_set_current_win(wins[1])
                vim.cmd("startinsert")
            else
                -- Create a new split and set the buffer
                vim.cmd(split_cmd)
                vim.api.nvim_win_set_buf(0, M.term_buf)
                vim.cmd("startinsert")
            end
        end
    else
        -- Start new aider instance
        vim.cmd(split_cmd)
        
        -- Set buffer options for terminal
        vim.bo.buftype = "nofile"
        vim.bo.buflisted = false
        
        -- Open terminal with aider
        local job_id = vim.fn.termopen(M.config.command, {
            on_exit = function()
                M.term_job = nil
                M.term_buf = nil
            end
        })
        
        -- Store the job and buffer IDs
        M.term_job = job_id
        M.term_buf = vim.api.nvim_get_current_buf()
        
        -- Enter insert mode automatically
        vim.cmd("startinsert")
    end
end

-- Create user command
vim.api.nvim_create_user_command("Aider", function()
    M.open_aider()
end, {})

return M
