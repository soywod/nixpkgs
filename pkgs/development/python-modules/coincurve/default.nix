{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  cmake,
  hatchling,
  ninja,
  pkg-config,
  setuptools,
  scikit-build-core,

  # dependencies
  asn1crypto,
  cffi,
  secp256k1,

  # checks
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "coincurve";
  version = "20.0.0";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "ofek";
    repo = "coincurve";
    tag = "v${version}";
    hash = "sha256-NKx/iLuzFEu1UBuwa14x55Ab3laVAKEtX6dtoWi0dOg=";
  };

  build-system = [
    hatchling
    cffi
    cmake
    ninja
    pkg-config
    setuptools
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;

  env.COINCURVE_IGNORE_SYSTEM_LIB = "OFF";

  buildInputs = [ secp256k1 ];

  dependencies = [
    asn1crypto
    cffi
  ];

  preCheck = ''
    # https://github.com/ofek/coincurve/blob/master/tox.ini#L20-L22=
    rm -rf coincurve

    # don't run benchmark tests
    rm tests/test_bench.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "coincurve" ];

  meta = with lib; {
    description = "Cross-platform bindings for libsecp256k1";
    homepage = "https://github.com/ofek/coincurve";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = [ ];
  };
}
