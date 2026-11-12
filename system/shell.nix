{
  pkgs,
  dotfiles,
  ...
}: let
  shellInit = name: cmd: {
    source = pkgs.runCommand "${name}-init.nu" {} "HOME=$TMPDIR ${cmd} > $out";
    clobber = true;
  };
in {
  hjem.users.m = {
    packages = with pkgs; [
      atuin
      zoxide
      carapace
    ];

    xdg.config.files =
      dotfiles.link "nushell" ["config.nu" "env.nu" "init.nu" "completions.nu" "aliases.nu"]
      // dotfiles.link "atuin" ["config.toml"]
      // {
        "user-dirs.dirs".text = ''
          XDG_DESKTOP_DIR="$HOME/"
          XDG_DOCUMENTS_DIR="$HOME/documents"
          XDG_DOWNLOAD_DIR="$HOME/downloads"
          XDG_MUSIC_DIR="$HOME/"
          XDG_PICTURES_DIR="$HOME/pictures"
          XDG_PUBLICSHARE_DIR="$HOME/"
          XDG_TEMPLATES_DIR="$HOME/"
          XDG_VIDEOS_DIR="$HOME/"
          XDG_PROJECTS_DIR="$HOME/projects"
        '';
      };

    xdg.data.files = {
      "zoxide/init.nu" = shellInit "zoxide" "${pkgs.zoxide}/bin/zoxide init nushell";
      "atuin/init.nu" = shellInit "atuin" "${pkgs.atuin}/bin/atuin init nu";
      "carapace/init.nu" = shellInit "carapace" "XDG_CONFIG_HOME=/home/m/.config ${pkgs.carapace}/bin/carapace _carapace nushell";
    };
  };
}
