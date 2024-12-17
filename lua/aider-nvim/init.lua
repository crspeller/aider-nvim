--- aider.nvim - A Neovim plugin for seamless integration with aider
--- @module aider-nvim
local M = {}

-- Store terminal job and buffer
M.term_job = nil
M.term_buf = nil

-- Track files being watched by aider
M.watched_files = {}

-- Default configuration
local default_config = {
    --- @type number Height of the terminal split in rows
    --- @type number Width of the terminal split in columns
    --- @type string Command to run for aider
    --- @type boolean Enable telescope integration
    -- Default height of the terminal split (in rows)
    terminal_height = 15,
    -- Default width of the terminal split (in columns)
    terminal_width = 80,
    -- Command to run
    command = "aider",
    -- Enable telescope integration
    use_telescope = true,
}

M.config = default_config

-- Track if plugin has been initialized
M.initialized = false

-- Function to setup the plugin with user config
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    M.initialized = true
end

-- Function to send command to aider terminal
local function send_to_terminal(cmd)
    if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
        local chan = vim.api.nvim_buf_get_var(M.term_buf, "terminal_job_id")
        vim.api.nvim_chan_send(chan, cmd .. "\n")
    end
end

-- Function to add files to aider
function M.add_files(files)
    if #files > 0 then
        local cmd = "/add " .. table.concat(files, " ")
        send_to_terminal(cmd)
        -- Update watched files
        for _, file in ipairs(files) do
            table.insert(M.watched_files, file)
        end
        vim.notify("Added files to aider: " .. table.concat(files, ", "))
    end
end

-- Function to remove files from aider
function M.remove_files(files)
    if #files > 0 then
        local cmd = "/remove " .. table.concat(files, " ")
        send_to_terminal(cmd)
        -- Update watched files
        for _, file in ipairs(files) do
            for i, watched in ipairs(M.watched_files) do
                if watched == file then
                    table.remove(M.watched_files, i)
                    break
                end
            end
        end
        vim.notify("Removed files from aider: " .. table.concat(files, ", "))
    end
end

-- Function to setup telescope pickers
function M.setup_telescope()
    local ok, telescope = pcall(require, "telescope.builtin")
    if not ok then
        vim.notify("telescope.nvim is required for file picking functionality", vim.log.levels.WARN)
        return false
    end

    -- Add file picker
    vim.api.nvim_create_user_command("AiderAddFile", function()
        telescope.find_files({
            attach_mappings = function(prompt_bufnr, map)
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selections = action_state.get_selected_entry()
                    if selections then
                        M.add_files({selections.value})
                    end
                end)
                return true
            end,
        })
    end, {})

    -- Remove file picker
    vim.api.nvim_create_user_command("AiderRemoveFile", function()
        if #M.watched_files == 0 then
            vim.notify("No files currently tracked by aider", vim.log.levels.INFO)
            return
        end
        
        vim.fn.setqflist({}, ' ', {
            title = 'Aider Watched Files',
            items = vim.tbl_map(function(file)
                return {filename = file, text = "Currently tracked by aider"}
            end, M.watched_files)
        })
        
        telescope.quickfix({
            attach_mappings = function(prompt_bufnr, map)
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selections = action_state.get_selected_entry()
                    if selections then
                        M.remove_files({selections.filename})
                    end
                end)
                return true
            end,
        })
    end, {})

    return true
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

-- Initialize telescope if enabled
if M.config.use_telescope then
    M.setup_telescope()
end

-- Create user command
vim.api.nvim_create_user_command("Aider", function()
    M.open_aider()
end, {})

-- Parse terminal output to track files
vim.api.nvim_create_autocmd({"TermOpen"}, {
    pattern = "*",
    callback = function(ev)
        if vim.bo[ev.buf].channel == M.term_job then
            vim.api.nvim_buf_attach(ev.buf, false, {
                on_lines = function(_, buf, _, first_line, last_line)
                    local lines = vim.api.nvim_buf_get_lines(buf, first_line, last_line, false)
                    for _, line in ipairs(lines) do
                        -- Parse aider output to detect file changes
                        if line:match("^Added: ") then
                            local file = line:match("^Added: (.+)$")
                            if file then
                                table.insert(M.watched_files, file)
                            end
                        elseif line:match("^Removed: ") then
                            local file = line:match("^Removed: (.+)$")
                            if file then
                                for i, watched in ipairs(M.watched_files) do
                                    if watched == file then
                                        table.remove(M.watched_files, i)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end,
            })
        end
    end,
})

return M
