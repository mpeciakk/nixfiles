{dotfiles, ...}: {
  # rules name pc's PCI cards and keep its outputs awake; laptop audio should suspend
  hjem.users.m.xdg.config.files.wireplumber.source = dotfiles.source "config/wireplumber";
  hjem.users.m.xdg.config.files."dotfiles/wallpaper-dark.png".source = ./wallpaper-dark.png;
  hjem.users.m.xdg.config.files."dotfiles/wallpaper-light.png".source = ./wallpaper-light.png;

  hjem.users.m.xdg.config.files."niri/output.kdl".text = ''
    output "DP-2" {
        mode "3840x2160@143.851"
        scale 1.5
        position x=0 y=0
        variable-refresh-rate on-demand=true
        focus-at-startup
    }

    output "HDMI-A-1" {
        mode "1920x1080@144"
        scale 1.0
        position x=2560 y=0
        transform "90"

        layout {
            main-axis "vertical"
            default-column-width { proportion 0.5; }
        }
    }
  '';
}
