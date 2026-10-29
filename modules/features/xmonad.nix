{ self, inputs, ... }: {
  flake.nixosModules.xmonad = { pkgs, lib, ... }:
    let
      xmobarRc = pkgs.writeText "xmobarrc" ''
        Config { font = "JetBrainsMono Nerd Font 10"
               , additionalFonts = []
               , borderColor = "#313244"
               , border = NoBorder
               , bgColor = "#1e1e2e"
               , fgColor = "#cdd6f4"
               , alpha = 255
               , position = TopSize C 100 24
               , textOffset = -1
               , iconOffset = -1
               , lowerOnStart = True
               , pickBroadest = False
               , persistent = False
               , hideOnStart = False
               , allDesktops = True
               , overrideRedirect = True
               , commands = [ Run Cpu ["-t", "CPU: <total>%", "-L", "3", "-H", "50", "--normal", "#a6e3a1", "--high", "#f38ba8"] 20
                            , Run Memory ["-t", "RAM: <usedratio>%"] 20
                            , Run Date "%a, %d %b  %H:%M" "date" 10
                            , Run UnsafeXPropertyLog "_XMONAD_LOG"
                            ]
               , sepChar = "%"
               , alignSep = "}{"
               , template = " %_XMONAD_LOG% }{ %cpu%  <fc=#45475a>|</fc>  %memory%  <fc=#45475a>|</fc>  <fc=#89b4fa>%date%</fc> "
               }
      '';
    in
    {
      imports = [
        self.nixosModules.urxvt
      ];

      services.xserver = {
        enable = true;
        windowManager.xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = hp: [
            hp.xmonad-contrib
            hp.xmonad-extras
          ];
          config = ''
            import XMonad
            import XMonad.Util.EZConfig (additionalKeysP)
            import XMonad.Util.Ungrab
            import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
            import XMonad.Hooks.ManageDocks (avoidStruts, docks, ToggleStruts(..))
            import XMonad.Hooks.StatusBar
            import XMonad.Hooks.StatusBar.PP
            import XMonad.Layout.Spacing (spacingRaw, Border(..))
            import XMonad.Layout.NoBorders (smartBorders)
            import qualified XMonad.StackSet as W

            import System.Exit (exitWith, ExitCode(..))

            myTerminal :: String
            myTerminal = "urxvt"

            myModMask :: KeyMask
            myModMask = mod4Mask -- Tecla Super / Windows

            myBorderWidth :: Dimension
            myBorderWidth = 2

            myNormalBorderColor :: String
            myNormalBorderColor = "#313244"

            myFocusedBorderColor :: String
            myFocusedBorderColor = "#89b4fa"

            -- Layouts com espaçamento minimalista (gaps)
            myLayout = smartBorders . avoidStruts $ (gapped tiled ||| gapped (Mirror tiled) ||| Full)
              where
                tiled   = Tall nmaster delta ratio
                nmaster = 1
                ratio   = 1/2
                delta   = 3/100
                gapped  = spacingRaw False (Border 1 1 1 1) True (Border 1 1 1 1) True

            -- Barra de status XMobar
            myStatusBar :: StatusBarConfig
            myStatusBar = statusBarProp "${pkgs.xmobar}/bin/xmobar ${xmobarRc}" (pure myXmobarPP)

            myXmobarPP :: PP
            myXmobarPP = def
              { ppCurrent         = xmobarColor "#89b4fa" "" . wrap "[" "]"
              , ppVisible         = xmobarColor "#89b4fa" ""
              , ppHidden          = xmobarColor "#6c7086" ""
              , ppHiddenNoWindows = const ""
              , ppUrgent          = xmobarColor "#f38ba8" "" . wrap "!" "!"
              , ppTitle           = xmobarColor "#cdd6f4" "" . shorten 45
              , ppSep             = "  <fc=#45475a>|</fc>  "
              }

            -- Hook de inicialização: define layout de teclado ABNT2, fundo preto, cursor e sincroniza ambiente para systemd/dbus
            myStartupHook :: X ()
            myStartupHook = do
              spawn "setxkbmap -layout br"
              spawn "xsetroot -solid '#000000' -cursor_name left_ptr"
              spawn "systemctl --user import-environment DISPLAY XAUTHORITY"
              spawn "dbus-update-activation-environment --systemd DISPLAY XAUTHORITY"

            -- Atalhos customizados em formato EZConfig (legíveis e fáceis de editar)
            myKeys :: [(String, X ())]
            myKeys =
              [ -- Aplicações e Terminal
                ("M-<Return>", spawn myTerminal)
              , ("M-<Space>", spawn "dmenu_run -fn 'JetBrainsMono Nerd Font-11' -nb '#1e1e2e' -nf '#cdd6f4' -sb '#89b4fa' -sf '#1e1e2e'")

              -- Fechar Janela (Mod + q)
              , ("M-q", kill)

              -- Janelas Flutuantes (Mod + w e Mod + Shift + w para voltar ao mosaico/tiling)
              , ("M-w", withFocused $ windows . W.sink)
              , ("M-S-w", withFocused $ windows . W.sink)

              -- Navegação e Foco de Janelas (Vim hjkl e Setas)
              , ("M-h", windows W.focusUp)
              , ("M-j", windows W.focusDown)
              , ("M-k", windows W.focusUp)
              , ("M-l", windows W.focusDown)
              , ("M-<Left>", windows W.focusUp)
              , ("M-<Down>", windows W.focusDown)
              , ("M-<Up>", windows W.focusUp)
              , ("M-<Right>", windows W.focusDown)
              , ("M-m", windows W.focusMaster)
              , ("M-<Tab>", windows W.focusDown)

              -- Mover / Trocar Janelas de Posição (Vim hjkl e Setas)
              , ("M-S-h", windows W.swapUp)
              , ("M-S-j", windows W.swapDown)
              , ("M-S-k", windows W.swapUp)
              , ("M-S-l", windows W.swapDown)
              , ("M-S-<Left>", windows W.swapUp)
              , ("M-S-<Down>", windows W.swapDown)
              , ("M-S-<Up>", windows W.swapUp)
              , ("M-S-<Right>", windows W.swapDown)
              , ("M-S-<Return>", windows W.swapMaster)

              -- Redimensionar Janela Mestre
              , ("M-C-h", sendMessage Shrink)
              , ("M-C-l", sendMessage Expand)
              , ("M-,", sendMessage (IncMasterN 1))
              , ("M-.", sendMessage (IncMasterN (-1)))

              -- Layouts
              , ("M-e", sendMessage NextLayout)
              , ("M-b", sendMessage ToggleStruts)

              -- Gerenciamento de Sessão (Mod+Shift+r restart, Mod+Shift+e exit)
              , ("M-S-r", spawn "xmonad --restart")
              , ("M-S-e", io (exitWith ExitSuccess))

              -- Controles de Áudio (WirePlumber / PipeWire)
              , ("<XF86AudioRaiseVolume>", spawn "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
              , ("<XF86AudioLowerVolume>", spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
              , ("<XF86AudioMute>", spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
              , ("<XF86AudioMicMute>", spawn "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")

              -- Screenshots rápidos
              , ("M-S-<Print>", unGrab *> spawn "flameshot gui")
              , ("M-<Print>", unGrab *> spawn "maim -s | xclip -selection clipboard -t image/png")
              , ("<Print>", unGrab *> spawn "maim | xclip -selection clipboard -t image/png")
              ]

            myConfig = withSB myStatusBar . ewmhFullscreen . ewmh . docks $ def
              { terminal           = myTerminal
              , modMask            = myModMask
              , borderWidth        = myBorderWidth
              , normalBorderColor  = myNormalBorderColor
              , focusedBorderColor = myFocusedBorderColor
              , layoutHook         = myLayout
              , startupHook        = myStartupHook
              } `additionalKeysP` myKeys

            main :: IO ()
            main = getDirectories >>= launch myConfig
          '';
        };
      };

      # Ferramentas essenciais e ultra-leves para o X11
      environment.systemPackages = with pkgs; [
        xmobar        # Barra de status ultra-leve para XMonad
        dmenu         # Menu minimalista suckless
        xclip         # Clipboard para o X11
        xsel          # Utilitário de manipulação de clipboard X11
        maim          # Screenshot leve
        xdotool       # Utilitário de automação X11
        setxkbmap     # Configuração de mapa de teclado no X11
        xsetroot      # Configuração de propriedades do root window (cursor/cor)
      ];

      # Picom ultra-leve para VSync (eliminar screen tearing sem bloat)
      services.picom = {
        enable = true;
        vSync = true;
        backend = "glx";
        settings = {
          corner-radius = 0;
          fading = false;
          shadow = false;
        };
      };
    };
}
