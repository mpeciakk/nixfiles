-- Neovim runtime and plugins as library, unless the project brings its own .luarc
return {
  on_init = function(client)
    local folder = client.workspace_folders and client.workspace_folders[1]
    if folder and (vim.uv.fs_stat(folder.name .. "/.luarc.json") or vim.uv.fs_stat(folder.name .. "/.luarc.jsonc")) then
      return
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
      runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
      workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
    })
  end,
  settings = { Lua = {} },
}
