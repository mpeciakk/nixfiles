{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.hjem.nixosModules.default];

  hjem.users.m = {
    user = "m";
    directory = "/home/m";

    packages = with pkgs; [ripgrep];

    xdg.config.files = {
      # test 1: plik w /nix/store (read-only)
      "hjem-test/store.txt".text = "hjem: plik ze store'a\n";

      # test 2: string zamiast ścieżki Nixa → symlink poza store, edycja na żywo.
      # Wniosek z kodu hjem (`source` typu path), do potwierdzenia na build-vm.
      "hjem-test/live".source = "/home/m/dotfiles/config/quickshell";
    };
  };
}
