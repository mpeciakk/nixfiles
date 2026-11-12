-- configs come from nvim-lspconfig's lsp/ dir, overrides from after/lsp/
vim.lsp.enable({ "lua_ls", "nixd", "clangd", "tsc", "biome", "cssls", "tinymist" })

vim.lsp.inlay_hint.enable(true)

local severity = vim.diagnostic.severity
vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  float = { source = true },
  signs = {
    text = {
      [severity.ERROR] = "󰅚 ",
      [severity.WARN] = "󰀪 ",
      [severity.INFO] = "󰋽 ",
      [severity.HINT] = "󰌶 ",
    },
  },
})

local map = vim.keymap.set
-- 0.12 defaults cover the rest: K, grn, gra, grr, gri, grt, gO, [d, ]d, <C-w>d, insert <C-s>
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action (gra)" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol (grn)" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "clangd" then
      map("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", { buffer = args.buf, desc = "Source/header" })
    end
  end,
})
