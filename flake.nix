{
  description = "A Nix-flake-based Elixir development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs = inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: inputs.nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
        };
      });
    in
    {
      overlays.default = final: prev: rec {
        # ==== ERLANG ====

        # use latest version of Erlang 27
        erlang = final.beam.interpreters.erlang_27;

        # ==== BEAM packages ====

        # all BEAM packages will be compile with your preferred erlang version
        pkgs-beam = final.beam.packagesWith erlang;

        # ==== Elixir ====

        # use latest version of Elixir 1.17
        elixir = pkgs-beam.elixir_1_17;
      };

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # use the Elixr/OTP versions defined above; will also install OTP, mix, hex, rebar3
            elixir

            # mix needs it for downloading dependencies
            git

            # containers + build tooling
            podman
            gnumake
            nodejs_20
          ]
          ++
          # Linux only
          pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
            gigalixir
            inotify-tools
            libnotify
          ])
          ++
          # macOS only
          pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            terminal-notifier
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
          ]);
        };
      });
    };
}
