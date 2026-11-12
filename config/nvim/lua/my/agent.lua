local map = vim.keymap.set

-- References for pasting into an agent prompt: path relative to cwd, current line or visual range.
local function selected_lines()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  return math.min(a, b), math.max(a, b)
end

local function reference(first, last)
  local path = vim.fn.expand("%:.")
  if path == "" then
    return nil
  end
  return first == last and ("%s#L%d"):format(path, first) or ("%s#L%d-%d"):format(path, first, last)
end

local function copy(text, what)
  if not text then
    vim.notify("Buffer has no file name", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", text)
  if vim.fn.mode():match("[vV\22]") then
    vim.cmd("normal! \27")
  end
  vim.notify("Copied " .. what)
end

map({ "n", "x" }, "<leader>ap", function()
  local ref = reference(selected_lines())
  copy(ref, ref)
end, { desc = "Copy path#L" })

map("x", "<leader>ay", function()
  local first, last = selected_lines()
  local ref = reference(first, last)
  if not ref then
    return copy(nil)
  end
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  -- the fence must be longer than any backtick run inside, or a selected fence would end the block
  local longest = 2
  for _, line in ipairs(lines) do
    for run in line:gmatch("`+") do
      longest = math.max(longest, #run)
    end
  end
  local fence = ("`"):rep(longest + 1)
  local ft = vim.bo.filetype
  local block = { ref, fence .. (vim.treesitter.language.get_lang(ft) or ft) }
  vim.list_extend(block, lines)
  table.insert(block, fence)
  copy(table.concat(block, "\n"), ref .. " as a block")
end, { desc = "Copy selection as block" })

-- An nvim that Claude itself spawned (Ctrl-G, git commit) must not register as an IDE.
if vim.env.CLAUDECODE then
  return
end

-- Claude runs in a herdr pane; this side only serves /ide (lock file in ~/.claude/ide).
-- warn: at info it reports every start/stop of its server
require("claudecode").setup({ terminal = { provider = "none" }, log_level = "warn" })

map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add buffer to Claude" })
map("x", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude's diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude's diff" })
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("my.agent", {}),
  pattern = "oil",
  callback = function(args)
    map("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = args.buf, desc = "Add file to Claude" })
  end,
})
