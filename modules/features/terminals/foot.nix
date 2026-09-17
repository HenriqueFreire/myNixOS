{ self, inputs, ... }: {
  flake.nixosModules.foot = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myFoot
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.myFoot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          pad = "12x12 center";
          term = "xterm-256color";
        };
        colors-dark = {
          alpha = 0.95;
          background = "1e1e2e";
          foreground = "cdd6f4";
          scrollback-indicator = "1e1e2e 89b4fa";
        };
        cursor = {
          style = "beam";
          blink = "yes";
        };
        scrollback = {
          lines = 10000;
          indicator-position = "relative";
          indicator-format = "percentage";
        };
        key-bindings = {
          clipboard-copy = "Control+Shift+c XF86Copy";
          clipboard-paste = "Control+Shift+v Control+v XF86Paste";
        };
      };
    };
  };
}
