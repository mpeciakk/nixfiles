local map = vim.keymap.set
local fzf = require("fzf-lua")

fzf.setup()
-- code actions and other vim.ui.select prompts through the same picker
fzf.register_ui_select()

map("n", "<leader><space>", fzf.files, { desc = "Files" })
map("n", "<leader>/", fzf.live_grep, { desc = "Grep" })
map("n", "<leader>,", fzf.buffers, { desc = "Buffers" })

map("n", "<leader>ff", fzf.files, { desc = "Files" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fc", function()
  fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Neovim config files" })
map("n", "<leader>fg", fzf.git_status, { desc = "Changed files (git status)" })

map("n", "<leader>sg", fzf.live_grep, { desc = "Grep" })
map("n", "<leader>sw", fzf.grep_cword, { desc = "Word under cursor" })
map("x", "<leader>sw", fzf.grep_visual, { desc = "Selection" })
map("n", "<leader>sd", fzf.diagnostics_document, { desc = "Diagnostics (buffer)" })
map("n", "<leader>sD", fzf.diagnostics_workspace, { desc = "Diagnostics (workspace)" })
map("n", "<leader>ss", fzf.lsp_document_symbols, { desc = "Symbols (buffer)" })
map("n", "<leader>sS", fzf.lsp_live_workspace_symbols, { desc = "Symbols (workspace)" })
map("n", "<leader>sh", fzf.helptags, { desc = "Help" })
map("n", "<leader>sk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>sr", fzf.resume, { desc = "Resume last search" })

require("oil").setup({
  skip_confirm_for_simple_edits = true,
  view_options = { show_hidden = true },
})
map("n", "-", "<cmd>Oil<cr>", { desc = "Files: current file's directory" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Files: current file's directory" })
map("n", "<leader>E", function()
  require("oil").open(vim.fn.getcwd())
end, { desc = "Files: cwd" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

require("mini.bufremove").setup()
map("n", "<leader>bd", function()
  MiniBufremove.delete()
end, { desc = "Delete buffer, keep window" })
map("n", "<leader>qr", "<cmd>restart<cr>", { desc = "Restart Neovim" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
