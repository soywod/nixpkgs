{ lib
, rustPlatform
, fetchFromGitHub
, stdenv
, pkg-config
, apple-sdk
, installShellFiles
, installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform
, installManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform
, notmuch
, gpgme
, withDefaultFeatures ? false
, withFeatures ? []
}:

let
  version = "1.0.0";
  hash = "sha256-NpkjnU4WBHnXHBoFqkMmX1l2xb038dDYsvWjNnpzBnM=";
  cargoHash = "sha256-pIrNSCqlRsx2QlknSVSGvkfoHenpzfTd1AAVywBzdpo=";
in

rustPlatform.buildRustPackage {
  inherit version cargoHash;

  pname = "himalaya";

  src = fetchFromGitHub {
    inherit hash;
    owner = "pimalaya";
    repo = "himalaya";
    rev = "v${version}";
  };

  buildNoDefaultFeatures = withDefaultFeatures;
  buildFeatures = withFeatures;

  nativeBuildInputs = [ pkg-config ]
    ++ lib.optional (installManPages || installShellCompletions) installShellFiles;

  buildInputs = [ ]
    ++ lib.optional stdenv.hostPlatform.isDarwin apple-sdk
    ++ lib.optional (builtins.elem "notmuch" withFeatures) notmuch
    ++ lib.optional (builtins.elem "pgp-gpg" withFeatures) gpgme;

  # most of the tests are lib side
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/{applications,completions,man}
    cp assets/himalaya.desktop "$out"/share/applications/
  '' + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    "$out"/bin/himalaya man "$out"/share/man
  '' + lib.optionalString installManPages ''
    installManPage "$out"/share/man/*
  '' + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    "$out"/bin/himalaya completion bash > "$out"/share/completions/himalaya.bash
    "$out"/bin/himalaya completion elvish > "$out"/share/completions/himalaya.elvish
    "$out"/bin/himalaya completion fish > "$out"/share/completions/himalaya.fish
    "$out"/bin/himalaya completion powershell > "$out"/share/completions/himalaya.powershell
    "$out"/bin/himalaya completion zsh > "$out"/share/completions/himalaya.zsh
  '' + lib.optionalString installShellCompletions ''
    installShellCompletion "$out"/share/completions/himalaya.{bash,fish,zsh}
  '';

  meta = rec {
    description = "CLI to manage emails";
    mainProgram = "himalaya";
    homepage = "https://github.com/pimalaya/himalaya";
    changelog = "${homepage}/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ soywod toastal yanganto ];
  };
}
