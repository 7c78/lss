# pursls

`pursls` is a lightweight extraction of the purescript-language-server.

## Features

- **Tested on GNOME + Wayland**
- **Startup Build:** Runs `spago build` automatically.
- **Watch Mode:** Rebuilds on save.
- **LSP Support:** Definition, Hover, and References providers.

## Installation

```
git clone https://github.com/7c78/lss.git
cd lss/pursls
nix develop
make install
```

## Usage

### Neovim

Add this to your configuration:

```lua
vim.lsp.enable("pursls")
vim.lsp.config("pursls", {
    cmd = { "pursls", "--stdio" },
    filetypes = { "purescript" },
    root_markers = { "spago.yaml" },
})
```
