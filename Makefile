# Get the Neovim configuration directory
NVIM_CONFIG_DIR ?= $(HOME)/.config/nvim

# Plugin directory
PLUGIN_DIR = $(NVIM_CONFIG_DIR)/pack/plugins/start/aider.nvim

.PHONY: install clean dirs

dirs:
	@echo "NVIM_CONFIG_DIR = $(NVIM_CONFIG_DIR)"
	@echo "PLUGIN_DIR      = $(PLUGIN_DIR)"

install:
	@echo "Installing aider.nvim..."
	@mkdir -p $(PLUGIN_DIR)
	@cp -r lua plugin README.md $(PLUGIN_DIR)/
	@echo "Installation complete!"

clean:
	@echo "Removing aider.nvim..."
	@rm -rf $(PLUGIN_DIR)
	@echo "Cleanup complete!"
