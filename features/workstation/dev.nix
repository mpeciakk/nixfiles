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

    # ~/.claude/skills to zwykły katalog z linkiem na każdy skill: obok publicznych z repo
    # mogą stać prywatne, a skille synchronizowane przez Claude'a nie lądują w repo
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
      # skill z danymi firmowymi: poza publicznym repo, w ~/work (mutagen)
      // {".claude/skills/knowledge-transfer".source = "/home/m/work/claude/knowledge-transfer";};
  };
}
