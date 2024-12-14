if vim.g.loaded_aider_nvim then
    return
end

local ok, _ = pcall(require, "aider-nvim")
if not ok then
    vim.notify("aider-nvim module not found", vim.log.levels.ERROR)
    return
end

vim.g.loaded_aider_nvim = true
