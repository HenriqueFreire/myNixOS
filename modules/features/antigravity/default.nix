{ self, inputs, ... }: {
  flake.nixosModules.antigravity = { pkgs, lib, config, ... }: {
    options.programs.antigravity = {
      enable = lib.mkEnableOption "Google Antigravity CLI agent";
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Extra packages to make available in systemPackages for Antigravity.";
      };
    };

    config = lib.mkIf config.programs.antigravity.enable {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "antigravity-cli"
      ];
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      ] ++ config.programs.antigravity.extraPackages;
    };
  };

  perSystem = { pkgs, lib, ... }: {
    packages.antigravity-cli = pkgs.symlinkJoin {
      name = "antigravity-cli";
      paths = [ pkgs.antigravity-cli ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/agy \
          --prefix PATH : ${lib.makeBinPath [
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.coreutils
            pkgs.uv
          ]}
      '';
    };
  };
}
