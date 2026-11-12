-- :TypstPreview — live preview in the browser
require("typst-preview").setup({
  -- both are on the wrapper's PATH; naming them skips the plugin's binary download
  dependencies_bin = { tinymist = "tinymist", websocat = "websocat" },
})

-- <leader>cp — the PDF in a herdr pane to the right: tinymist exports it on save (after/lsp/tinymist.lua)
-- and tdf reloads it when the file changes.
local panes = {} -- pdf path -> herdr pane id

local function herdr(args)
  local res = vim.system(vim.list_extend({ "herdr" }, args), { text = true }):wait()
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr)
  end
  -- pane run answers with nothing
  return res.stdout ~= "" and vim.json.decode(res.stdout) or {}
end

local function toggle_pdf_pane()
  if vim.env.HERDR_ENV ~= "1" then
    vim.notify("PDF pane needs herdr; :TypstPreview opens the browser preview", vim.log.levels.WARN)
    return
  end
  local pdf = vim.fn.expand("%:p:r") .. ".pdf"
  if panes[pdf] and herdr({ "pane", "get", panes[pdf] }) then
    herdr({ "pane", "close", panes[pdf] })
    panes[pdf] = nil
    return
  end
  local tdf = vim.fn.exepath("tdf")
  if tdf == "" then
    vim.notify("PDF pane: tdf not on PATH (it comes with the nixfiles wrapper)", vim.log.levels.WARN)
    return
  end
  local name = vim.fs.basename(pdf)
  -- single quotes read the same in nu and bash, but cannot hold a quote
  if name:find("'", 1, true) then
    vim.notify("PDF pane: file name contains a quote: " .. name, vim.log.levels.WARN)
    return
  end
  if not vim.uv.fs_stat(pdf) then
    vim.cmd.write()
    if not vim.wait(5000, function()
      return vim.uv.fs_stat(pdf) ~= nil
    end, 100) then
      vim.notify("PDF pane: no " .. name .. " after save (compile error?)", vim.log.levels.WARN)
      return
    end
  end
  local split, err =
    herdr({ "pane", "split", "--current", "--direction", "right", "--cwd", vim.fs.dirname(pdf), "--no-focus" })
  if not split then
    vim.notify("PDF pane: " .. err, vim.log.levels.ERROR)
    return
  end
  local id = split.result.pane.pane_id
  panes[pdf] = id
  -- exec: the pane closes when tdf quits
  herdr({ "pane", "run", id, ("exec '%s' '%s'"):format(tdf, name) })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("my.typst", {}),
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<leader>cp", toggle_pdf_pane, { buffer = args.buf, desc = "PDF preview (herdr pane)" })
  end,
})
