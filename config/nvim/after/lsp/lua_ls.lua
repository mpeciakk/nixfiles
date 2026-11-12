-- Neovim runtime and plugins as library, only for this config: loading them delays diagnostics by
-- ~10 s, and other Lua projects have no use for Neovim's API.
return {
  on_init = function(client)
    local folder = client.workspace_folders and client.workspace_folders[1]
    local config = vim.uv.fs_realpath(vim.fn.stdpath("config"))
    if not folder or vim.uv.fs_realpath(folder.name) ~= config then
      return
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
      runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
      workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
    })
  end,
  settings = { Lua = {} },
}
