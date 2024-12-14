if vim.g.loaded_aider_nvim then
    return
end
vim.g.loaded_aider_nvim = true

-- Load the main module
require("aider-nvim")
