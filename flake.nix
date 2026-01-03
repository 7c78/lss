{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        purescript-overlay.url = "github:thomashoneyman/purescript-overlay";
    };

    outputs = { self, nixpkgs, purescript-overlay }:
        let system = "x86_64-linux";
            pkgs = import nixpkgs {
                inherit system;
                overlays = [
                    purescript-overlay.overlays.default
                ];
            };
        in {
            devShells.${system}.default = pkgs.mkShell {
                nativeBuildInputs = [
                    pkgs.nodejs_24
                    pkgs.esbuild
                    pkgs.purs
                    pkgs.spago-unstable
                ];
            };
        };
}
