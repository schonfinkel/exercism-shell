_:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      devenv.shells.elixir = {
        packages = with pkgs; [
          elixir-ls
          exercism
        ];

        languages.elixir.enable = true;

        env = {
          LOCALE_ARCHIVE = lib.optionalString pkgs.stdenv.isLinux "${pkgs.glibcLocales}/lib/locale/locale-archive";
          LANG = "en_US.UTF-8";
        };

        enterShell = ''
          echo "Starting Elixir environment..."
          exercism version
        '';
      };
    };
}
