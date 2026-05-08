_:
{
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells.gleam = {
        packages = [ pkgs.exercism ];

        languages.gleam.enable = true;

        enterShell = ''
          echo "Starting Gleam environment..."
          exercism version
        '';
      };
    };
}
