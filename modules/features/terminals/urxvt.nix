{ self, inputs, ... }: {
  flake.nixosModules.urxvt = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myUrxvt
    ];
  };

  perSystem = { pkgs, lib, ... }:
    let
      # Plugins do urxvt para funcionalidades essenciais modernas
      rxvtBase = pkgs.rxvt-unicode.override {
        configure = { availablePlugins, ... }: {
          plugins = with availablePlugins; [
            perls
            resize-font
            vtwheel
          ];
        };
      };

      # Configuração clássica Xresources estilizada de forma minimalista
      xresourcesConfig = pkgs.writeText "urxvt-xresources" ''
        ! ==========================================
        ! URxvt Minimalist Configuration
        ! ==========================================

        ! Tipografia e Espaçamento
        URxvt.font: xft:JetBrainsMono Nerd Font:size=11:antialias=true:hinting=true
        URxvt.boldFont: xft:JetBrainsMono Nerd Font:bold:size=11:antialias=true:hinting=true
        URxvt.italicFont: xft:JetBrainsMono Nerd Font:italic:size=11:antialias=true:hinting=true
        URxvt.letterSpace: -1
        URxvt.lineSpace: 0
        URxvt.internalBorder: 12
        URxvt.externalBorder: 0

        ! Barra de rolagem (Scrollbar) estilizada
        URxvt.scrollBar: true
        URxvt.scrollBar_right: true
        URxvt.scrollBar_floating: true
        URxvt.scrollstyle: plain
        URxvt.scrollColor: #585b70
        URxvt.troughColor: #181825
        URxvt.borderLess: false

        ! Comportamento de rolagem e buffer
        URxvt.saveLines: 10000
        URxvt.scrollTtyOutput: false
        URxvt.scrollWithBuffer: true
        URxvt.scrollTtyKeypress: true

        ! Desativar ISO 14755 (essencial para liberar Ctrl+Shift para copiar/colar)
        URxvt.iso14755: false
        URxvt.iso14755_52: false

        ! Cursor
        URxvt.cursorBlink: true
        URxvt.cursorUnderline: false
        URxvt.cursorColor: #cdd6f4

        ! Extensões Perl (Clipboard, Redimensionamento de fonte, URLs)
        URxvt.perl-ext-common: default,clipboard,url-select,resize-font,keyboard-select
        URxvt.url-select.launcher: ${lib.getExe' pkgs.xdg-utils "xdg-open"}
        URxvt.url-select.underline: true

        ! Configuração do Clipboard (Integração com xclip)
        URxvt.clipboard.copycmd: ${lib.getExe' pkgs.xclip "xclip"} -i -selection clipboard
        URxvt.clipboard.pastecmd: ${lib.getExe' pkgs.xclip "xclip"} -o -selection clipboard
        URxvt.clipboard.autocopy: true

        ! Atalhos de teclado (Copiar/Colar e Zoom de Fonte)
        URxvt.keysym.Control-Shift-C: perl:clipboard:copy
        URxvt.keysym.Shift-Control-C: perl:clipboard:copy
        URxvt.keysym.Control-Shift-V: perl:clipboard:paste
        URxvt.keysym.Shift-Control-V: perl:clipboard:paste
        URxvt.keysym.C-S-C: perl:clipboard:copy
        URxvt.keysym.C-S-V: perl:clipboard:paste
        URxvt.keysym.M-c: perl:clipboard:copy
        URxvt.keysym.M-v: perl:clipboard:paste
        URxvt.keysym.Control-plus: perl:resize-font:bigger
        URxvt.keysym.Control-minus: perl:resize-font:smaller
        URxvt.keysym.Control-equal: perl:resize-font:reset

        ! Paleta de Cores Minimalista (Dark / Catppuccin Mocha)
        URxvt.background: #1e1e2e
        URxvt.foreground: #cdd6f4

        ! Black
        URxvt.color0:  #45475a
        URxvt.color8:  #585b70
        ! Red
        URxvt.color1:  #f38ba8
        URxvt.color9:  #f38ba8
        ! Green
        URxvt.color2:  #a6e3a1
        URxvt.color10: #a6e3a1
        ! Yellow
        URxvt.color3:  #f9e2af
        URxvt.color11: #f9e2af
        ! Blue
        URxvt.color4:  #89b4fa
        URxvt.color12: #89b4fa
        ! Magenta
        URxvt.color5:  #f5c2e7
        URxvt.color13: #f5c2e7
        ! Cyan
        URxvt.color6:  #94e2d5
        URxvt.color14: #94e2d5
        ! White
        URxvt.color7:  #bac2de
        URxvt.color15: #a6adc8
      '';
    in
    {
      packages.myUrxvt = pkgs.symlinkJoin {
        name = "my-urxvt";
        paths = [ rxvtBase ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for bin in urxvt urxvtc urxvtd; do
            if [ -e "$out/bin/$bin" ]; then
              wrapProgram "$out/bin/$bin" \
                --set XENVIRONMENT "${xresourcesConfig}" \
                --prefix PATH : ${lib.makeBinPath [ pkgs.xclip pkgs.xsel pkgs.xdg-utils ]}
            fi
          done
        '';
      };
    };
}
