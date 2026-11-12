local group = vim.api.nvim_create_augroup("my", {})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- the agent edits files that are open here
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = group,
  callback = function()
    -- inside an autocmd :checktime is only queued; scheduled it runs right after
    vim.schedule(function()
      -- E11 in the command-line window
      if vim.fn.getcmdwintype() == "" then
        vim.cmd.checktime()
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if #vim.treesitter.query.get_files(lang, "indents") > 0 then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
