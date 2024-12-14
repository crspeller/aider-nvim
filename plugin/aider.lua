if vim.version().minor < 5 then
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

vim.g.loaded_aider_nvim = true
