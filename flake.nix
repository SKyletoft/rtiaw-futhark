{
	inputs = {
		nixpkgs.url     = "github:nixos/nixpkgs/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem(system:
			let
				pkgs = nixpkgs.legacyPackages.${system};
				lib = nixpkgs.lib;
			in rec {
				devShells.default = pkgs.mkShell {
					nativeBuildInputs = with pkgs; [
						futhark
						rocmPackages.clr
						pkg-config
						hyperfine

						rustc
						cargo
						clippy
						rustfmt
						rust-analyzer
					];
					ROCMCLR = "${pkgs.rocmPackages.clr}";
					LIBOPENCL_BIN = "${pkgs.ocl-icd}";
				};
			}
		);
}
