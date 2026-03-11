{
  description = "C++ template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, devshell, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ devshell.overlays.default ];
    };
    csh = pkgs.runCommand "csh" {} ''
      mkdir -p $out/bin
      ln -s ${pkgs.tcsh}/bin/tcsh $out/bin/csh
    '';
  in {
    devShells.default = pkgs.devshell.mkShell {
      name = "gr-chombo";

      packages = (with pkgs; [
        perl
        unzip
        llvmPackages_20.clang-tools
        nodejs
        xmake
        cmake
        gnumake
        ninja
        lapack
        blas
        mpi
        hdf5
        gfortran15
      ]) ++ [csh];

      env = [
        {
          name = "CHOMBO_HOME";
          eval = "$(pwd)/chombo/lib";
        }
      ];

      devshell.startup.locale.text = ''
        export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
      '';

      devshell.startup.ldflags.text = ''
        export NIX_LDFLAGS="$NIX_LDFLAGS -L${pkgs.gfortran15.cc.lib}/lib -L${pkgs.lapack}/lib -L${pkgs.blas}/lib"
        export XTRALDFLAGS="$XTRALDFLAGS -llapack -lblas"
      '';

      devshell.startup.gcc_stdenv.text = ''
        export CC=${pkgs.gcc15}/bin/gcc
        export CXX=${pkgs.gcc15}/bin/g++
      '';
    };
  });
}
