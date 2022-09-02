{
  description = "Parameterized calculations using Nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }: let
    linspace = { start, stop, num }: let
      step = (stop - start) / (num - 1);
    in builtins.genList (x: start + x * step) num;

    arange = { start, stop, step }: let
      num = builtins.floor ( (stop - start) / step );
    in builtins.genList (x: start + x * step ) num; 
  in {
    lib = {
      inherit arange linspace;
    };
  } // (flake-utils.lib.eachSystem ["x86_64-linux" ] (system: let
    pkgs = (import nixpkgs) {inherit system;};
      
    
    writeReferences = drvs: pkgs.writeText "data" (pkgs.lib.concatStringsSep "\n" drvs);

    mapParams = defaultAttrs: attrsets: map (attrs: defaultAttrs // attrs) (pkgs.lib.cartesianProductOfSets attrsets);


  in rec {

    builders = let

      build = { executable, name, parameters}: pkgs.runCommand name {
        passthru = {
          inherit parameters;
        };
      } ''
        ${executable} ${builtins.toFile "parameters.json" (builtins.toJSON parameters)} "$out"
      '';

      # Perform a parameterized computation.
      compute = { fixedParameters, variableParameters, executable, name }: let
        parameters = mapParams fixedParameters variableParameters;
        build_ = params: build { inherit executable name; parameters = params;};
        drvs = map build_ parameters;
      in writeReferences drvs;

    in {
      inherit compute;
    };

    checks = {
      compute = builders.compute {
        fixedParameters = {
          a = 1;
          b = 2;
        };
        variableParameters = {
          c = [1 2 3];
        };
        executable = "${pkgs.python3.interpreter} ${./check.py}";
        name = "result.json";
        };
    };
  }));
}
