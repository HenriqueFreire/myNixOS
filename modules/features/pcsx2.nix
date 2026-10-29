{ self, inputs, ... }: {
  flake.nixosModules.pcsx2 = { pkgs, ... }: {
    # PCSX2: Emulador de PlayStation 2
    # Requer suporte a gráficos 32-bit para plugins legados (já habilitado via hardware.graphics)
    environment.systemPackages = with pkgs; [
      pcsx2
    ];
  };
}
