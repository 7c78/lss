SRC_DIR := $(shell pwd)
BIN_NAME := pursls
BUNDLE_FILE := server.js
INSTALL_PATH := $(HOME)/.local/bin/$(BIN_NAME)

.PHONY: install bundle uninstall

node_modules: package.json
	@echo "Installing NPM dependencies..."
	npm install
	@touch node_modules

bundle: node_modules
	@echo "Bundling PureScript project..."
	spago bundle

install: bundle
	@echo "Installing $(BIN_NAME) to $(HOME)/.local/bin..."
	ln -sf $(SRC_DIR)/$(BUNDLE_FILE) $(INSTALL_PATH)
	@echo "Done."

uninstall:
	rm -f $(INSTALL_PATH)
	@echo "Uninstalled $(BIN_NAME)."
