{ self, inputs, ... }: {
  flake.nixosModules.firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      languagePacks = [ "pt-BR" ];

      # Políticas de sistema que o Firefox aplica ao iniciar
      policies = {
        # 1. Privacidade, remoção de telemetria e recursos invasivos
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DontCheckDefaultBrowser = true;

        # 2. Instalação automática das extensões essenciais
        ExtensionSettings = {
          # Firefox Multi-Account Containers oficial
          "@testpilot-containers" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
          };
          # uBlock Origin (economia substancial de RAM e bloqueio de anúncios/scripts)
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
        };

        # 3. Definição declarativa dos seus Containers
        Containers = {
          Default = [
            {
              name = "Lacrei Saúde";
              icon = "briefcase";
              color = "red";
            }
            {
              name = "Senac";
              icon = "briefcase";
              color = "blue";
            }
            {
              name = "Univesp";
              icon = "tree";
              color = "green";
            }
            {
              name = "Pessoal";
              icon = "chill";
              color = "yellow";
            }
          ];
        };

        # 4. Ajustes finos de performance, RAM e aceleração por GPU Intel
        Preferences = {
          # Habilita suporte e interface a Multi-Account Containers
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;

          # Descarrega abas inativas da memória quando o sistema estiver sob pressão de RAM
          "browser.tabs.unloadOnLowMemory" = true;

          # Aceleração de vídeo em hardware na GPU Intel (VA-API para YouTube, Teams, reuniões)
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.enabled" = true;

          # Reduz consumo de CPU/GPU eliminando animações cosméticas da UI
          "toolkit.cosmeticAnimations.enabled" = false;

          # Evita pré-carregamento especulativo desnecessário de links
          "network.prefetch-next" = false;
        };
      };
    };
  };
}
