{pkgs, ...}: {
  config.programs.opencode = {
    enable = true;
    package = pkgs.hello;
  };
  config.home.packages = with pkgs; [
    mcp-server-git
  ];
}
