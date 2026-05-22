{
  pkgs,
  ...
}: {
  config.programs.opencode = {
    enable = true;
    package = pkgs.hello;
  };
}
