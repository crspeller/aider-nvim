# Get the Neovim configuration directory
NVIM_CONFIG_DIR ?= $(HOME)/.config/nvim

# Plugin directories
PLUGIN_DIR = $(NVIM_CONFIG_DIR)/pack/plugins/start/aider.nvim
LUA_DIR = $(PLUGIN_DIR)/lua
PLUGIN_FILES_DIR = $(PLUGIN_DIR)/plugin

.PHONY: install clean dirs

dirs:
	@echo "NVIM_CONFIG_DIR = $(NVIM_CONFIG_DIR)"
	@echo "PLUGIN_DIR      = $(PLUGIN_DIR)"
	@echo "LUA_DIR         = $(LUA_DIR)"
	@echo "PLUGIN_FILES_DIR = $(PLUGIN_FILES_DIR)"

install:
	@echo "Installing aider.nvim..."
	@mkdir -p $(LUA_DIR)/aider-nvim
	@mkdir -p $(PLUGIN_FILES_DIR)
	@cp lua/aider-nvim/init.lua $(LUA_DIR)/aider-nvim/
	@cp plugin/aider.lua $(PLUGIN_FILES_DIR)/
	@cp -r README.md $(PLUGIN_DIR)/
	@echo "Installation complete!"

clean:
	@echo "Removing aider.nvim..."
	@rm -rf $(PLUGIN_DIR)
	@echo "Cleanup complete!"
