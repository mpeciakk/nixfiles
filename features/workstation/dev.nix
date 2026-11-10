{pkgs, ...}: {
  hjem.users.m = {
    packages = with pkgs; [
      claude-code
      nodejs
      bun
      uv
      lazydocker
    ];

    xdg.config.files."uv/uv.toml".text = ''
      python-preference = "only-managed"
    '';
  };
}
