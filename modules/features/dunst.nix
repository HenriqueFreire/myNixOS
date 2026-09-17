{ self, inputs, ... }: {
  flake.nixosModules.dunst = { pkgs, ... }: {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 10";
          frame_width = 2;
          frame_color = "#89b4fa";
          corner_radius = 0;
          offset = "16x16";
          origin = "top-right";
          padding = 12;
          horizontal_padding = 12;
        };
        urgency_low = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          timeout = 5;
        };
        urgency_normal = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          timeout = 8;
        };
        urgency_critical = {
          background = "#1e1e2e";
          foreground = "#f38ba8";
          frame_color = "#f38ba8";
          timeout = 0;
        };
      };
    };
  };
}
