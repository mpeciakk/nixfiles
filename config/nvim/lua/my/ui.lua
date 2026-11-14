-- kitty draws the background (background_opacity 0.8)
require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
vim.cmd.colorscheme("catppuccin")

require("mini.icons").setup()
-- oil, diffview and others look for nvim-web-devicons
MiniIcons.mock_nvim_web_devicons()

require("mini.notify").setup()
vim.notify = MiniNotify.make_notify()

-- branch and diff counts come from gitsigns
require("mini.statusline").setup()

require("which-key").setup({
  preset = "modern",
  spec = {
    { "<leader>a", group = "agent" },
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git/review" },
    { "<leader>h", group = "hunk" },
    { "<leader>q", group = "quit" },
    { "<leader>s", group = "search" },
    { "<leader>t", group = "toggle" },
  },
})
