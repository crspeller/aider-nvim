# Get the Neovim configuration directory
NVIM_CONFIG_DIR ?= $(HOME)/.config/nvim/pack/plugins/start

# Plugin directory
PLUGIN_DIR = $(NVIM_CONFIG_DIR)/aider.nvim

.PHONY: install clean dirs

dirs:
	@echo "NVIM_CONFIG_DIR = $(NVIM_CONFIG_DIR)"
	@echo "PLUGIN_DIR      = $(PLUGIN_DIR)"

install:
	@echo "Installing aider.nvim..."
	@mkdir -p $(PLUGIN_DIR)/lua/aider-nvim
	@mkdir -p $(PLUGIN_DIR)/plugin
	@cp lua/aider-nvim/init.lua $(PLUGIN_DIR)/lua/aider-nvim/
	@cp plugin/aider.lua $(PLUGIN_DIR)/plugin/
	@cp README.md $(PLUGIN_DIR)/
	@echo "Installation complete!"

clean:
	@echo "Removing aider.nvim..."
	@rm -rf $(PLUGIN_DIR)
	@echo "Cleanup complete!"
