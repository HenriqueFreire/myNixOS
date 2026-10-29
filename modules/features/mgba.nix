{ self, inputs, ... }: {
  flake.nixosModules.mgba = { pkgs, ... }: {
    # mGBA: Emulador rápido, preciso e moderno de Game Boy Advance, GB e GBC
    environment.systemPackages = with pkgs; [
      mgba
    ];
  };
}
