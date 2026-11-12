{
  pkgs,
  lib,
  dotfiles,
  ...
}: let
  # parsers and their queries are plugin dependencies, so they only reach packpath through the wrapper
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
    with p; [
      bash
      c
      cpp
      css
      diff
      dockerfile
      git_config
      git_rebase
      gitcommit
      gitignore
      html
      java
      javascript
      jsdoc
      json
      kdl
      lua
      make
      markdown
      markdown_inline
      nix
      nu
      python
      qmljs
      query
      regex
      sql
      toml
      tsx
      typescript
      typst
      vim
      vimdoc
      xml
      yaml
    ]);

  tools = with pkgs; [
    lua-language-server
    stylua
    nixd
    alejandra
    clang-tools
    typescript
    biome
    vscode-langservers-extracted
    tinymist
    websocat
    tdf
    fzf
    fd
  ];

  neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    # native code from Nix (built from source); pure-Lua plugins come from vim.pack
    plugins = [treesitter pkgs.vimPlugins.blink-cmp];
    wrapRc = false;
    # appended: a project's devshell or node_modules/.bin wins
    wrapperArgs = ["--suffix" "PATH" ":" (lib.makeBinPath tools)];
  };
in {
  hjem.users.m = {
    packages = [neovim];
    # whole dir: vim.pack writes nvim-pack-lock.json through the link into the repo
    xdg.config.files = dotfiles.linkDir "nvim";
  };
}
