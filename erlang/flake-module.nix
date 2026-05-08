_:
{
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells.erlang = {
        packages = with pkgs; [
          erlang-language-platform
          erlfmt
          rebar3
          watchman
          exercism
        ];

        languages.erlang.enable = true;

        scripts = {
          rebar = {
            exec = "rebar3";
            packages = [ pkgs.rebar3 ];
          };
        };

        enterShell = ''
          echo "Starting Erlang environment..."
          exercism version
        '';
      };
    };
}
