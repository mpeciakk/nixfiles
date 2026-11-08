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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  security.soteria.enable = true;
  systemd.user.services.polkit-soteria.serviceConfig.ExecStart = lib.mkForce (pkgs.writeShellScript "soteria-session" ''
    export XDG_SESSION_ID=$(${pkgs.systemd}/bin/loginctl show-user "$USER" -p Display --value)
    exec ${lib.getExe pkgs.soteria}
  '');

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];
}
