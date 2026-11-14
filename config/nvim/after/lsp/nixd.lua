-- nixpkgs and NixOS options as pinned by this flake (the repo path is fixed, see README)
local flake = '(builtins.getFlake "/home/m/projects/nixfiles")'

return {
  settings = {
    nixd = {
      nixpkgs = { expr = "import " .. flake .. ".inputs.nixpkgs { }" },
      -- laptop's options are pc's plus nixos-apple-silicon; a pc-only options module would need its own entry
      options = { nixos = { expr = flake .. ".nixosConfigurations.laptop.options" } },
    },
  },
}
