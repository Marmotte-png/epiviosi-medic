{
  lib,
  symlinkJoin,
  writeShellApplication,
  gocryptfs,
  util-linux,
  coreutils,
  zenity,
  xdg-utils,
  modeles,
}:
let
  coffre = writeShellApplication {
    name = "epiviosi-medic-coffre";
    runtimeInputs = [
      gocryptfs
      util-linux
      coreutils
    ];
    runtimeEnv.EPIVIOSI_MEDIC_MODELES = "${modeles}";
    text = builtins.readFile ./epiviosi-medic-coffre.sh;
  };
  dossiers = writeShellApplication {
    name = "epiviosi-medic-dossiers";
    runtimeInputs = [
      coffre
      zenity
      xdg-utils
    ];
    text = builtins.readFile ./epiviosi-medic-dossiers.sh;
  };
in
symlinkJoin {
  name = "epiviosi-medic-coffre";
  paths = [
    coffre
    dossiers
  ];
  meta.description = "Coffre chiffré « Dossiers médicaux » d'EPIVÍOSI MEDIC";
}
