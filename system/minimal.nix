# NixOS defaults nothing here uses; man pages stay
{
  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };
  # EDITOR is nvim, which sits in the system profile (features/workstation/neovim.nix)
  programs.nano.enable = false;
  system.tools.nixos-generate-config.enable = false;
}
