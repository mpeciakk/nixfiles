{pkgs, ...}: {
  hjem.users.m.packages = with pkgs; [
    kitty
    quickshell
    xwayland-satellite
    cliphist
    wl-clipboard
    mangohud
    ripgrep
    atuin
    zoxide
    carapace
    bat
  ];
}
