{
  inputs,
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
