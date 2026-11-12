-- nixpkgs and NixOS options as pinned by this flake (the repo path is fixed, see README)
local flake = '(builtins.getFlake "/home/m/projects/nixfiles")'

return {
  settings = {
    nixd = {
      nixpkgs = { expr = "import " .. flake .. ".inputs.nixpkgs { }" },
      options = { nixos = { expr = flake .. ".nixosConfigurations.pc.options" } },
    },
  },
}
