{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTANT
      settings =
        let
          jsonFile = ./noctalia.json;
          content = if builtins.pathExists jsonFile then builtins.readFile jsonFile else "{}";
          parsed = if content != "" then builtins.fromJSON content else {};
        in
        parsed.settings or parsed;
    };
  };
}
