{ self, inputs, ... }: {
  flake.nixosModules.simplescreenrecorder = { pkgs, ... }: {
    # SimpleScreenRecorder: Gravador de tela gráfico para X11
    # Excelente para gravar o jogo Plantão de Raios-X e apresentações
    environment.systemPackages = with pkgs; [
      simplescreenrecorder
    ];
  };
}
