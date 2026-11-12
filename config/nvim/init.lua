-- The Nix wrapper (features/workstation/neovim.nix) ships parsers, blink.cmp and the tools. On a host
-- not switched to it yet, stay vanilla instead of installing plugins against the wrong binary.
if #vim.api.nvim_get_runtime_file("parser/nix.so", false) == 0 then
  vim.notify("nvim without the nixfiles wrapper: config skipped", vim.log.levels.WARN)
  return
end

vim.g.mapleader = " "

require("my.options")
require("my.pack")
require("my.ui")
require("my.autocmds")
require("my.lsp")
require("my.completion")
require("my.format")
require("my.editing")
require("my.navigation")
