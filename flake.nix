{
  description = "C++ template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux" 
  ] (system: let
    pkgs = import nixpkgs {
      inherit system;
    };
    csh = pkgs.runCommand "csh" {} ''
      mkdir -p $out/bin
      ln -s ${pkgs.tcsh}/bin/tcsh $out/bin/csh
    '';
  in {
    devShells.default = pkgs.mkShell.override {
      # stdenv = pkgs.llvmPackages_20.stdenv;
      stdenv = pkgs.gcc15Stdenv;
    } rec {
      name = "gr-chombo";

      packages = (with pkgs; [
        perl
        unzip          # for xmake repo
        llvmPackages_20.clang-tools # for clang-format and clangd
        nodejs
      ]) ++ [csh];

      buildInputs = with pkgs; [
        xmake
        cmake
        gnumake
        ninja
        lapack
        blas
        mpi
        hdf5
        perl
        gcc15
        gfortran15
      ];
      shellHook = ''
        export CHOMBO_HOME="$(pwd)/chombo/lib"
        export NIX_LDFLAGS="$NIX_LDFLAGS -L${pkgs.gfortran15.cc.lib}/lib -L${pkgs.lapack}/lib -L${pkgs.blas}/lib"
        export XTRALDFLAGS="$XTRALDFLAGS -llapack -lblas"
      '';
    };
  });
}
