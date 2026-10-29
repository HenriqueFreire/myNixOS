{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.antigravity
      self.nixosModules.xmonad
      self.nixosModules.urxvt
      self.nixosModules.dunst
      self.nixosModules.neovim
      self.nixosModules.git
      self.nixosModules.docker
      self.nixosModules.firefox
      self.nixosModules.tor-browser
      self.nixosModules.simplescreenrecorder
      self.nixosModules.android
      self.nixosModules.pcsx2
      self.nixosModules.yt-dlp
      self.nixosModules.mgba
      self.nixosModules.workspaceMcp
    ];

    programs.antigravity.enable = true;
    programs.antigravity.mcp.workspace.enable = true;

    # 1. Bootloader e Parâmetros de Kernel
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = [
      "i915.enable_fbc=1"   # Framebuffer Compression (economiza largura de banda de RAM e energia)
      "i915.fastboot=1"     # Elimina flickering de vídeo durante o boot
    ];
    system.stateVersion = "26.05";

    # 2. Rede e Hostname (iwd + systemd-networkd para ultra-baixo consumo)
    networking.hostName = "nixos";
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" ];
    networking.networkmanager.enable = false;
    networking.wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = false; # systemd-networkd gerencia DHCP/IP
        };
      };
    };
    networking.useNetworkd = true;

    # Resolução de DNS com fallback seguro
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "allow-downgrade";
        FallbackDNS = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" ];
      };
    };

    systemd.network.enable = true;
    systemd.network.networks."10-wired" = {
      matchConfig.Name = [ "enp*" "eth*" ];
      DHCP = "yes";
      networkConfig = {
        IPv6PrivacyExtensions = "kernel";
        DNS = [ "1.1.1.1" "8.8.8.8" ];
      };
      dhcpV6Config.UseDNS = false;
      ipv6AcceptRAConfig.UseDNS = false;
    };
    systemd.network.networks."20-wireless" = {
      matchConfig.Name = [ "wlan*" "wlp*" ];
      DHCP = "yes";
      networkConfig = {
        IPv6PrivacyExtensions = "kernel";
        DNS = [ "1.1.1.1" "8.8.8.8" ];
      };
      dhcpV6Config.UseDNS = false;
      ipv6AcceptRAConfig.UseDNS = false;
    };

    # Desativar Bluetooth por completo (hardware, drivers e rádio)
    hardware.bluetooth.enable = false;
    hardware.bluetooth.powerOnBoot = false;
    boot.blacklistedKernelModules = [ "bluetooth" "btusb" "btrtl" "btintel" "btmtk" "btbcm" ];

    # 3. Fuso horário e Localização
    time.timeZone = "America/Sao_Paulo";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };

    # 4. Teclado (Console TTY e Servidor Gráfico/Wayland) e Touchpad
    console.keyMap = "br-abnt2";
    services.xserver = {
      enable = true;
      xkb = {
        layout = "br";
        variant = "";
      };
      displayManager.startx.enable = true;
    };

    services.libinput = {
      enable = true;
      touchpad = {
        tapping = true;                # Habilita toque para clicar (tap-to-click)
        naturalScrolling = true;       # Rolagem natural (estilo smartphone/macOS)
        scrollMethod = "twofinger";    # Rolagem com dois dedos
        disableWhileTyping = true;     # Evita toques acidentais ao digitar
      };
    };

    # 5. Áudio (PipeWire) e Gráficos
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
      ];
    };

    # Gerenciamento térmico para processadores Intel
    services.thermald.enable = true;

    # 6. Segurança, Usuário e Permissões
    security.polkit.enable = true;
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    users.users."henrique" = {
      isNormalUser = true;
      description = "Henrique";
      extraGroups = [ "wheel" "video" "audio" "render" ];
    };

    # 7. Fontes
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
    ];

    # 8. Otimização de Memória (zram, journald, oomd) e Armazenamento no SSD
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100; # Garante prioridade sobre a partição de swap no SSD NVMe
    };

    # Limitar retenção de logs do journald em RAM e desativar oomd
    services.journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=16M
    '';
    systemd.oomd.enable = false;

    # Ajustes finos do kernel para ZRAM e responsividade
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    # Garante a existência do diretório de cache de alta performance no SSD NVMe
    systemd.tmpfiles.rules = [
      "d /var/cache/henrique 0700 henrique users -"
    ];

    # 9. Integração de Desktop e Portais (Screenshots, Diálogos de Arquivo)
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    # 10. Pacotes e Funcionalidades do Nix
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    # Coleta de lixo automática e otimização da store ("Jeito Nix")
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    nix.optimise.automatic = true;

    environment.systemPackages = with pkgs; [
      flameshot         # Ferramenta gráfica completa para captura e anotação de screenshots
      libva-utils       # Utilitário vainfo para checar aceleração por hardware (VA-API)
      wget
      pavucontrol       # Interface para controlar volume e portas do Pipewire
      alsa-utils        # Utilitários ALSA (alsamixer, amixer, arecord)
      pulseaudio        # Utilitários PulseAudio (pactl)
      libnotify         # Notificações do sistema
      btop              # Monitor de recursos TUI
      yazi              # Gerenciador de arquivos TUI com suporte a imagens
      ueberzugpp        # Suporte a renderização de imagens e miniaturas no URxvt / X11
      ffmpegthumbnailer # Miniaturas de vídeos para o Yazi
      imagemagick       # Manipulação e renderização de imagens extras e SVGs
      poppler-utils     # Pré-visualização de arquivos PDF no Yazi (pdftoppm)
      chafa             # Renderizador visual auxiliar
      fzf               # Fuzzy finder
      mpv               # Player de vídeo minimalista acelerado por hardware
      cmus              # Player de música TUI ultra-leve
    ];
  };

}
