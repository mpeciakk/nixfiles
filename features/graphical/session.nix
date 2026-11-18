{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.niri = {
    enable = true;
    package = inputs.biri.packages.${pkgs.stdenv.hostPlatform.system}.niri.overrideAttrs {doCheck = false;};
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.niri = {
      prettyName = "Niri";
      comment = "niri (biri)";
      binPath = "/run/current-system/sw/bin/niri-session";
    };
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd 'uwsm start niri-session'";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Qt file dialogs (Prism Launcher) through the portal, i.e. yazi
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
  };

  security.soteria.enable = true;
  systemd.user.services.polkit-soteria.serviceConfig.ExecStart = lib.mkForce (pkgs.writeShellScript "soteria-session" ''
    export XDG_SESSION_ID=$(${pkgs.systemd}/bin/loginctl show-user "$USER" -p Display --value)
    exec ${lib.getExe pkgs.soteria}
  '');

  services.gnome.gcr-ssh-agent.enable = false;

  # explicit preference so the portal reports light rather than "no preference"
  programs.dconf.profiles.user.databases = [{settings."org/gnome/desktop/interface".color-scheme = "prefer-light";}];

  # journald applies a system unit's LogLevelMax to its whole cgroup: drops xwayland-satellite's debug flood
  systemd.services."user@".serviceConfig.LogLevelMax = "info";

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-termfilechooser];
    # the rest of config.niri comes from the NixOS niri module
    config.niri."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
  };

  # file picker = yazi in kitty; no --single-instance, it would return before the choice is made.
  # User config: the system one is read from the package's own etc/xdg in the store, not /etc/xdg.
  hjem.users.m.xdg.config.files."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir=$HOME
    env=TERMCMD=kitty --class termfilechooser
    open_mode=suggested
    save_mode=last
  '';

  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = ["Noto Sans"];
    serif = ["Noto Serif"];
    monospace = ["JetBrainsMono Nerd Font"];
    emoji = ["Noto Color Emoji"];
  };
}
