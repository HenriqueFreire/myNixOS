{ self, inputs, ... }: {
  flake.nixosModules.git = { pkgs, lib, ... }: {

    # 1. Habilitar o ssh-agent do sistema e aliases de host
    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        # Perfil Pessoal
        Host github.com-personal
            HostName github.com
            User git
            IdentityFile ~/.ssh/id_ed25519
            AddKeysToAgent yes

        # Perfil Lacrei Saúde (Trabalho)
        Host github.com-lacrei
            HostName github.com
            User git
            IdentityFile ~/.ssh/id_lacrei
            AddKeysToAgent yes
      '';
    };

    # 2. Configuração declarativa do Git e perfis
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";

        # Perfil Pessoal padrão (usado em todo o sistema)
        user = {
          name = "HenriqueFreire";
          email = "henriquefreire@outlook.com.br";
        };

        # Regra condicional: dentro de ~/Trabalho/ aplica o perfil da Lacrei Saúde
        includeIf."gitdir:~/Trabalho/" = {
          path = pkgs.writeText "gitconfig-lacrei" ''
            [user]
                name = Henrique Freire
                email = henrique.freire@lacreisaude.com.br
          '';
        };
      };
    };

    # 3. Ferramentas adicionais úteis para o workflow Git
    environment.systemPackages = with pkgs; [
      gh          # GitHub CLI oficial
      lazygit     # Interface Git no terminal (TUI)
    ];
  };
}
