{
  pkgs,
  dotfiles,
  ...
}: {
  hjem.users.m = {
    packages = with pkgs; [
      ripgrep
      bat
      git
      (python3.withPackages (ps: [ps.pyyaml])) # pyyaml: lint vaulta sprawdza składnię frontmattera
      jq
      herdr
      lazygit
      yazi
      sshfs
      socat
    ];

    xdg.config.files =
      dotfiles.link "dotfiles" ["config.json"]
      // dotfiles.link "herdr" ["config.toml" "plugins/config/herdr-navigator/config.toml"]
      // builtins.mapAttrs (_: f: f // {clobber = true;}) (
        dotfiles.link "git" ["config" "ignore" "allowed_signers"]
      );

    files = dotfiles.bin ["herdr-here" "herdr-ssh" "claude-baseline"];
  };
}
