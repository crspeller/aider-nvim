local has_nvim_0_5 = vim.fn.has("nvim-0.5.0") == 1
if not has_nvim_0_5 then
    vim.notify("aider.nvim requires Neovim >= 0.5.0", vim.log.levels.ERROR)
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
