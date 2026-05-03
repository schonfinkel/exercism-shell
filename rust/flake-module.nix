_:
{
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells.rust = {
        packages = with pkgs; [
          rust-analyzer
          clippy
          rustfmt
          cargo-watch
          exercism
        ];

        languages.rust.enable = true;

        enterShell = ''
          echo "Starting Rust environment..."
          rustc --version
          cargo --version
          exercism version
        '';
      };
    };
}
