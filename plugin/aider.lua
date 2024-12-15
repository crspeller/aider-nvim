-- Check for minimum Neovim version
if vim.fn.has("nvim-0.5") ~= 1 then
    vim.notify("aider.nvim requires Neovim >= 0.5", vim.log.levels.ERROR)
    return
end

if vim.g.loaded_aider_nvim then
    return
end

local ok, aider = pcall(require, "aider-nvim")
if not ok then
    vim.notify("aider-nvim module not found", vim.log.levels.ERROR)
    return
end

-- Initialize with default config if not already setup
if not aider.initialized then
    aider.setup()
end

vim.g.loaded_aider_nvim = true
