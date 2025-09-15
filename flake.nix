{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      devenv,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { pkgs, system, ... }:
        let

          # Elixir
          getElixirLibs =
            elixirLsPkg:
            let
              elixirLsPath = "${elixirLsPkg}/bin";
              launcher = "${elixirLsPath}/elixir-ls";
            in
            {
              path = elixirLsPath;
              launcher = launcher;
            };

          mkElixirEnvVars = pkgs: elixirLibs: {
            LOCALE_ARCHIVE = pkgs.lib.optionalString pkgs.stdenv.isLinux "${pkgs.glibcLocales}/lib/locale/locale-archive";
            LANG = "en_US.UTF-8";
            # Language Server
            ELIXIR_LS_PATH = elixirLibs.launcher;
          };

          elixirLibs = getElixirLibs pkgs.elixir-ls;

          # F#
          dotnet_8 =
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_8_0
            ];

          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        in
        {
          # This sets `pkgs` to a nixpkgs with allowUnfree option set.
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          # nix develop
          devShells = {
            # Rust environemnt support
            # nix develop .#rust
            rust = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, lib, ... }:
                  {
                    packages = with pkgs; [
                      rust-analyzer
                      clippy
                      rustfmt
                      cargo-watch
                      exercism
                    ];

                    languages.rust = {
                      enable = true;
                    };

                    enterShell = ''
                      echo "Starting Rust environment..."
                      rustc --version
                      cargo --version
                      exercism version
                    '';
                  }
                )
              ];

            };

            # Erlang Environment
            # `nix develop .#erlang`
            erlang = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, lib, ... }:
                  {
                    packages = with pkgs; [
                      erlang-ls
                      erlfmt
                      rebar3
                      exercism
                    ];

                    languages.erlang = {
                      enable = true;
                    };

                    enterShell = ''
                      echo "Starting Erlang environment..."
                      exercism version
                    '';
                  }
                )
              ];
            };

            # Elixir Environment
            # `nix develop .#elixir`
            elixir = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, lib, ... }:
                  {
                    packages = with pkgs; [
                      elixir-ls
                      exercism
                    ];

                    languages.elixir = {
                      enable = true;
                    };

                    env = mkElixirEnvVars pkgs elixirLibs;

                    enterShell = ''
                      echo "Starting Elixir environment..."
                      exercism version
                    '';
                  }
                )
              ];
            };

            # F# Environment
            # `nix develop .#fsharp`
            fsharp = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, lib, ... }:
                  {
                    packages = with pkgs; [
                      exercism

                      # .Net
                      icu
                      netcoredbg
                      fsautocomplete
                      fantomas
                    ];

                    languages.dotnet = {
                      enable = true;
                      package = dotnet_8;
                    };

                    enterShell = ''
                      echo "Starting F# environment..."
                      exercism version
                    '';
                  }
                )
              ];
            };

            # Gleam Environment
            # `nix develop .#gleam`
            gleam = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, lib, ... }:
                  {
                    packages = with pkgs; [
                      exercism
                    ];

                    languages.gleam = {
                      enable = true;
                    };

                    enterShell = ''
                      echo "Starting Gleam environment..."
                      exercism version
                    '';
                  }
                )
              ];
            };

            # Haskell Environment
            # `nix develop .#haskell`
            haskell = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, lib, ... }:
                  {
                    packages = with pkgs; [
                      exercism
                    ];

                    languages.haskell = {
                      enable = true;
                    };

                    enterShell = ''
                      echo "Starting Haskell environment..."
                      exercism version
                    '';
                  }
                )
              ];
            };
          };

          # nix fmt
          formatter = treefmtEval.config.build.wrapper;
        };

      flake = {
      };
    };
}
