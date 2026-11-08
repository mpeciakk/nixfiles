{inputs, ...}: {
  imports = [inputs.hjem.nixosModules.default];

  hjem.users.m = {
    user = "m";
    directory = "/home/m";
  };
}
