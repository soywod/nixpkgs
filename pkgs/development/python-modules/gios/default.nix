{
  lib,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  dacite,
  fetchFromGitHub,
  pytest-asyncio,
  pytest-error-for-skips,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "gios";
  version = "6.0.0";
  pyproject = true;

  disabled = pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "bieniu";
    repo = "gios";
    tag = version;
    hash = "sha256-SCVyEHxTV+6+3mLh8HEutRXHV2Xt0JzOrNnIKtIcFXw=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    dacite
  ];

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-error-for-skips
    pytestCheckHook
    syrupy
  ];

  disabledTests = [
    # Test requires network access
    "test_invalid_station_id"
  ];

  pythonImportsCheck = [ "gios" ];

  meta = with lib; {
    description = "Python client for getting air quality data from GIOS";
    homepage = "https://github.com/bieniu/gios";
    changelog = "https://github.com/bieniu/gios/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
