_:
{
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells.fsharp = {
        packages = with pkgs; [
          icu
          fsautocomplete
          fantomas
          exercism
        ];

        languages.dotnet = {
          enable = true;
          package = pkgs.dotnet-sdk_10;
        };

        enterShell = ''
          echo "Starting F# environment..."
          exercism version
        '';
      };
    };
}
