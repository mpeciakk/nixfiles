local map = vim.keymap.set
local gitsigns = require("gitsigns")

gitsigns.setup({
  on_attach = function(buf)
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = buf, desc = desc })
    end
    local function lines()
      return { vim.fn.line("."), vim.fn.line("v") }
    end

    bmap("n", "]h", function()
      gitsigns.nav_hunk("next")
    end, "Next hunk")
    bmap("n", "[h", function()
      gitsigns.nav_hunk("prev")
    end, "Previous hunk")
    bmap("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
    bmap("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
    bmap("x", "<leader>hs", function()
      gitsigns.stage_hunk(lines())
    end, "Stage lines")
    bmap("x", "<leader>hr", function()
      gitsigns.reset_hunk(lines())
    end, "Reset lines")
    bmap("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
    bmap("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
    bmap("n", "<leader>hp", gitsigns.preview_hunk_inline, "Preview hunk inline")
    bmap("n", "<leader>gB", function()
      gitsigns.blame_line({ full = true })
    end, "Blame line")
  end,
})

map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "Toggle word diff" })

-- Review modes: gitsigns diffs against the same rev as the open review, so its marks match what
-- the review lists. Whatever closes the review (key, :tabclose, :DiffviewClose) restores the base.
-- shortcut: tracks one review; with two open, closing the older keeps the newer's base until it closes.
local review
local opening -- base of the review being opened; false = gitsigns default (index)

local function git(args)
  local res = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
  return res.code == 0 and vim.trim(res.stdout) or nil
end

-- only buffers of cwd's repo: in a buffer from another repo the rev is missing and gitsigns errors out.
-- shortcut: buffers opened during a review count from the index, fine while reviews are short.
local function set_base(base)
  local root = git({ "rev-parse", "--show-toplevel" })
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local s = vim.b[b].gitsigns_status_dict
    if s and s.root == root then
      vim.api.nvim_buf_call(b, function()
        gitsigns.change_base(base)
      end)
    end
  end
end

require("diffview").setup({
  hooks = {
    view_opened = function(view)
      if opening ~= nil then
        review = view
        set_base(opening or nil)
      end
    end,
    view_closed = function(view)
      if view == review then
        review = nil
        set_base(nil)
      end
    end,
  },
})

-- git and diffview both work from cwd, so the rev computed here exists in the repo diffview opens
local function open_review(rev, base)
  local args = { "-C" .. vim.fn.getcwd() }
  if rev then
    table.insert(args, 1, rev)
  end
  opening = base
  -- reset even when opening fails (E11 from the q: window), or the next diffview takes this base
  local ok, err = pcall(require("diffview").open, args)
  opening = nil
  if not ok then
    error(err, 0)
  end
end

-- origin/HEAD, else init.defaultBranch, else main or master as a local branch; else origin/HEAD's
-- remote branch (a clone made with -b has no local default branch)
local function default_branch()
  local origin = git({ "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
  local candidates = {
    origin and origin:gsub("^origin/", "") or false,
    git({ "config", "init.defaultBranch" }) or false,
    "main",
    "master",
  }
  for _, name in ipairs(candidates) do
    if name and git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. name }) then
      return name
    end
  end
  return origin
end

local function review_branch()
  local branch = default_branch()
  if not branch then
    vim.notify("Review branch: no origin/HEAD, init.defaultBranch, main or master here", vim.log.levels.WARN)
    return
  end
  if git({ "branch", "--show-current" }) == branch then
    vim.notify(("Review branch: on %s itself, nothing to compare"):format(branch), vim.log.levels.WARN)
    return
  end
  local base = git({ "merge-base", branch, "HEAD" })
  if not base then
    vim.notify(("Review branch: no common ancestor with %s"):format(branch), vim.log.levels.WARN)
    return
  end
  -- a single rev diffs against the working tree, the same comparison gitsigns makes
  open_review(base, base)
end

-- no rev: unstaged + staged + untracked (the files an agent just created), and staging still works;
-- gitsigns' default index base with staged signs shows the same set
map("n", "<leader>gd", function()
  open_review(nil, false)
end, { desc = "Review uncommitted" })
map("n", "<leader>gb", review_branch, { desc = "Review branch (vs merge-base)" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close review" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repo history" })
