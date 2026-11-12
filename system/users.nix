{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.hjem.nixosModules.default];

  users.mutableUsers = false;

  users.users = {
    root.hashedPassword = "!";

    m = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = ["wheel" "kvm" "dialout" "lp" "audio"];
      shell = pkgs.nushell;
      hashedPasswordFile = "/persist/secrets/m.passwd";
    };
  };

  environment.shells = [pkgs.nushell];
}
