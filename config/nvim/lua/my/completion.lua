require("blink.cmp").setup({
  keymap = { preset = "default" }, -- <C-y> accept, <C-n>/<C-p>, <C-space> menu/docs
  appearance = { nerd_font_variant = "mono" },
  completion = { documentation = { auto_show = true } },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  -- the Rust matcher is built by Nix; never download one
  fuzzy = { implementation = "rust", prebuilt_binaries = { download = false } },
})
