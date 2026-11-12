require("typst-preview").setup({
  -- both are on the wrapper's PATH; naming them skips the plugin's binary download
  dependencies_bin = { tinymist = "tinymist", websocat = "websocat" },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("my.typst", {}),
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<leader>cp", "<cmd>TypstPreviewToggle<cr>", { buffer = args.buf, desc = "Preview in browser" })
  end,
})
