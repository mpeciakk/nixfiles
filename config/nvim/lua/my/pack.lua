-- Pure-Lua plugins. Native ones (nvim-treesitter + parsers, blink.cmp) come from the Nix wrapper.
local specs = {
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/dlyongemallo/diffview-plus.nvim",
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/chomosuke/typst-preview.nvim",
}

-- vim.pack's lock repair writes any plugin dir still on disk back into the lockfile, which both
-- machines share. Before the first vim.pack call reads them, drop dirs that neither the list nor the
-- lockfile names; a dir the lockfile still names would be cloned back on every start.
-- Removing a plugin: drop its line, restart, then vim.pack.del({ name }) so the lockfile forgets it.
local wanted = {}
for _, src in ipairs(specs) do
  wanted[src:match("[^/]+$")] = true
end
local ok, locked = pcall(function()
  local lockfile = vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")
  return vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n")).plugins
end)
if ok and type(locked) == "table" then
  for name in pairs(locked) do
    wanted[name] = true
  end
end
local opt_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
for name, kind in vim.fs.dir(opt_dir) do
  if kind == "directory" and not wanted[name] then
    vim.fs.rm(vim.fs.joinpath(opt_dir, name), { recursive = true, force = true })
  end
end

vim.pack.add(specs, { confirm = false })

vim.api.nvim_create_user_command("PackSync", function()
  vim.pack.update(nil, { target = "lockfile" })
end, { desc = "Move installed plugins to the lockfile's revisions (after a change on the other machine)" })
