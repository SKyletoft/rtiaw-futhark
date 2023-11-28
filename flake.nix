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
						intel-compute-runtime
						opencl-headers
						ocl-icd
						intel-ocl
						pkg-config

						rustc
						cargo
						clippy
						rustfmt
						rust-analyzer
					];
				};
			}
		);
}
