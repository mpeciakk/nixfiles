-- Project-style formatters run only where the project configures them: with the tools on PATH, a
-- save would otherwise rewrite a whole file in the tool's default style.
local function configured(names)
  return function(_, ctx)
    return vim.fs.root(ctx.dirname, names) ~= nil
  end
end

local biome = { "biome" }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "alejandra" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    javascript = biome,
    javascriptreact = biome,
    typescript = biome,
    typescriptreact = biome,
    json = biome,
    jsonc = biome,
    css = biome,
    typst = { lsp_format = "prefer" }, -- tinymist's typstyle
  },
  formatters = {
    stylua = { condition = configured({ "stylua.toml", ".stylua.toml" }) },
    ["clang-format"] = { condition = configured({ ".clang-format", "_clang-format" }) },
    biome = { condition = configured({ "biome.json", "biome.jsonc" }) },
  },
  -- no LSP fallback: tsc/clangd/lua_ls would rewrite the file just the same
  default_format_opts = { lsp_format = "never" },
  -- a project without formatter config is the normal case, not a warning on every save
  notify_no_formatters = false,
  format_on_save = function(buf)
    if vim.g.format_on_save_off or vim.b[buf].format_on_save_off then
      return
    end
    return { timeout_ms = 3000 }
  end,
})

local function toggle(scope, label)
  return function()
    scope.format_on_save_off = not scope.format_on_save_off
    vim.notify(("Format on save (%s): %s"):format(label, scope.format_on_save_off and "off" or "on"))
  end
end

vim.keymap.set("n", "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>tf", toggle(vim.b, "buffer"), { desc = "Toggle format on save (buffer)" })
vim.keymap.set("n", "<leader>tF", toggle(vim.g, "global"), { desc = "Toggle format on save (global)" })
