{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = {
        lib,
        pkgs,
        system,
        config,
        ...
      }: 
      {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (inputs.fenix.overlays.default)
          ];
        };

        devShells.default = with pkgs; let 
        toolchain = pkgs.fenix.stable.withComponents [
          "rustc"
          "cargo"
          "clippy"
        ];
        in mkShell
        {
          packages = with pkgs; [
            openssl
            rust-analyzer
						gtk4 # needed for applcation to show 
            toolchain
          ] ++ lib.optionals stdenv.isDarwin [ 
						pkgs.apple-sdk_15 
					] ++ lib.optionals pkgs.stdenv.isLinux [ 
						pkgs.gcc

						# Audio libraries needed 
						pkgs.libjack2 
						pkgs.alsa-lib
					];
        };
      };
    };
}
