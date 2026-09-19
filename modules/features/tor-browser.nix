{ self, inputs, ... }: {
  flake.nixosModules.tor-browser = { pkgs, ... }: {
    # Tor Browser: Navegador focado em privacidade e anonimato através da rede Tor
    environment.systemPackages = with pkgs; [
      tor-browser
    ];
  };
}
