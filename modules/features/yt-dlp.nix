{ self, inputs, ... }: {
  flake.nixosModules.yt-dlp = { pkgs, ... }: {
    # yt-dlp: Utilitário CLI para download e streaming de vídeos (YouTube, Twitch, etc.)
    environment.systemPackages = with pkgs; [
      yt-dlp
    ];
  };
}
