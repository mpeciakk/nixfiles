{
  pkgs,
  dotfiles,
  ...
}: {
  # direnv + nix-direnv: a project's devShell loads on cd (.envrc with `use flake`).
  # The direnv module hooks nushell via programs.nushell.interactiveShellInit,
  # which is only installed (as a vendor autoload script) when programs.nushell is enabled.
  programs.direnv.enable = true;
  # the module sets it only in /etc/set-environment; pam_env reaches nushell TTY logins too
  environment.sessionVariables.DIRENV_CONFIG = "/etc/direnv";
  programs.nushell.enable = true;

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
