{ self, inputs, ... }: {
  flake.nixosModules.docker = { pkgs, ... }: {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
      daemon.settings = {
        "log-driver" = "local";
        "log-opts" = {
          "max-size" = "10m";
        };
      };
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Adiciona o usuário henrique ao grupo docker (permite usar docker sem sudo)
    users.users.henrique.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}
