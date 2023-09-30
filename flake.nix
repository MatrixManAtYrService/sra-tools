{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    ncbi-vdb = {
      url = "github:MatrixManAtYrService/ncbi-vdb";
      inputs.nixpkgs.follows = "nixpkgs";

      # when a release of ncbi-vdb is made which has a flake.nix, 
      # point at that version explicitly instead of tracking the default branch
      #url = "github:MatrixManAtYrService/ncbi-vdb?rev=3.0.9";

    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ncbi-vdb
    ,
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        ncbi-vdb-package = ncbi-vdb.packages.${system}.ncbi-vdb;
      in
      rec {
        packages = rec {
          sra-tools = pkgs.stdenv.mkDerivation {
            name = "sra-tools";
            src = self;

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.perl
              pkgs.which
              pkgs.file.dev # includes libmagic
              pkgs.libxml2.dev
              pkgs.mbedtls
              pkgs.flex
              pkgs.bison
              pkgs.jdk
              pkgs.python3
              pkgs.hdf5
            ];

            configurePhase = ''
              ./configure --with-ncbi-vdb-prefix=${ncbi-vdb-package} \
                          --with-magic-prefix=${pkgs.file.dev} \
                          --with-xml2-prefix=${pkgs.libxml2.dev} \
                          --build-prefix=$TMPDIR \
                          --prefix=$out
            '';

            enableParallelBuilding = true;

            meta = {
              license = pkgs.lib.licenses.publicDomain;
              description = "The SRA Toolkit and SDK from NCBI is a collection of tools and libraries for using data in the INSDC Sequence Read Archives.";
            };
          };
          default = sra-tools;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.cmake
            pkgs.perl
            pkgs.nixpkgs-fmt
          ];
        };
      }
      );
}

