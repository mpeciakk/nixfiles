{pkgs, ...}: {
  hjem.users.m.packages = with pkgs; [
    kitty
    quickshell
    xwayland-satellite
    cliphist
    wl-clipboard
    ripgrep
    atuin
    zoxide
    carapace
    bat
    git
    neovim
    python3
    jq
    claude-code
    mutagen
    nodejs
    bun
    uv
    zed-editor
    legcord
    mpv
    ffmpeg
    herdr
    lazygit
    superfile
    (runCommand "spf" {} "mkdir -p $out/bin && ln -s ${superfile}/bin/superfile $out/bin/spf")
    lazydocker
    sshfs
    socat
  ];
}
