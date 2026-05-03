_:
{
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells.haskell = {
        packages = [ pkgs.exercism ];

        languages.haskell.enable = true;

        enterShell = ''
          echo "Starting Haskell environment..."
          exercism version
        '';
      };
    };
}
