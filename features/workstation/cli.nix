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
      neovim
      python3
      jq
      herdr
      lazygit
      superfile
      (runCommand "spf" {} "mkdir -p $out/bin && ln -s ${superfile}/bin/superfile $out/bin/spf")
      sshfs
      socat
    ];

    xdg.config.files =
      dotfiles.link "dotfiles" ["config.json"]
      // dotfiles.link "herdr" ["config.toml" "plugins/config/herdr-navigator/config.toml"]
      // dotfiles.link "herdr-automatic-rename" ["config.sh"]
      // builtins.listToAttrs (map (n: {
        name = "git/${n}";
        value = {
          source = "${dotfiles.dot}/git/${n}";
          clobber = true;
        };
      }) ["config" "ignore"]);

    files = dotfiles.bin ["herdr-here" "herdr-ssh" "claude-baseline"];
  };
}
