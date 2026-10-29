{ self, inputs, ... }: {
  flake.nixosModules.android = { pkgs, ... }: {
    # 1. Permissões de usuário para depuração e transferência USB
    users.users.henrique.extraGroups = [ "adbusers" ];

    # 4. Pacotes CLI para transferência de arquivos, MTP e gerenciamento
    environment.systemPackages = with pkgs; [
      android-tools
      simple-mtpfs
      libmtp
    ];
  };
}
