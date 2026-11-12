{
  pkgs,
  dotfiles,
  ...
}: {
  hjem.users.m = {
    packages = with pkgs; [
      claude-code
      nodejs
      bun
      uv
      lazydocker
    ];

    xdg.config.files."uv/uv.toml".text = ''
      python-preference = "only-managed"
    '';

    # link per skill, not the whole dir: private and Claude-synced skills stay out of the repo
    files =
      builtins.listToAttrs (map (n: {
        name = ".claude/${n}";
        value = {
          source = dotfiles.source "config/claude/${n}";
          clobber = true;
        };
      }) ["settings.json" "CLAUDE.md" "agents" "hooks"])
      // builtins.listToAttrs (map (n: {
        name = ".claude/skills/${n}";
        value.source = dotfiles.source "config/claude/skills/${n}";
      }) (dotfiles.subdirs "config/claude/skills"))
      // {".claude/skills/knowledge-transfer".source = "/home/m/work/claude/knowledge-transfer";};
  };
}
