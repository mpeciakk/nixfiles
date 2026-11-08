{mylib}:
builtins.mapAttrs mylib.mkHost {
  pc = {
    system = "x86_64-linux";
    traits = ["graphical" "workstation" "gaming"];
  };
}
