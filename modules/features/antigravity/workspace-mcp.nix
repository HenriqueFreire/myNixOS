{ self, inputs, ... }: {
  flake.nixosModules.workspaceMcp = { pkgs, lib, config, ... }: {
    options.programs.antigravity.mcp.workspace = {
      enable = lib.mkEnableOption "Google Workspace MCP (Tasks, Calendar, Drive, Gmail) for Antigravity";
      toolTier = lib.mkOption {
        type = lib.types.enum [ "core" "extended" "complete" ];
        default = "core";
        description = "Tool tier to load into context (core covers Tasks, Calendar, Drive, Gmail; complete covers all 120+ tools).";
      };
    };

    config = lib.mkIf (config.programs.antigravity.enable && config.programs.antigravity.mcp.workspace.enable) {
      # Garante que uv esteja também no ambiente do sistema para uso manual e testes
      environment.systemPackages = [
        pkgs.uv
      ];
    };
  };
}
