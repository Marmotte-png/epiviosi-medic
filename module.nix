# EPIVÍOSI MEDIC : documentation médicale et dossiers chiffrés, hors-ligne.
#
# - Documentation : `epiviosi-medic-docs` télécharge des archives médicales
#   (≈ 4,4 Go) dans la bibliothèque d'EPIVÍOSI WIKI (si le module est activé).
# - Dossiers médicaux : coffre chiffré (gocryptfs) dans ~/Persistant, ouvert
#   avec une phrase de passe dans ~/Dossiers-médicaux, avec des modèles de
#   fiches LibreOffice (fiche patient, bilan secouriste, suivi de traitement).
# - Guide « EPIVÍOSI MEDIC » (numéros d'urgence, ressources) dans le menu.
#
# Ce module implémente `epiviosi.medic.enable`, déclarée par le socle
# EPIVÍOSI OS (modules/epiviosi-modules.nix).
{ config, lib, pkgs, ... }:
let
  cfg = config.epiviosi.medic;

  modeles = pkgs.callPackage ./templates { };
  coffre = pkgs.callPackage ./pkgs/epiviosi-medic-coffre { inherit modeles; };

  # Archives Kiwix (≈ 4,4 Go, en anglais), servies par le Kiwix d'EPIVÍOSI WIKI.
  docs = [
    "other/zimgit-medicine_en" # bibliothèque de survie, premiers secours
    "zimit/irp.fas.org_en_military-medicine" # médecine de terrain
    "zimit/nhs.uk_en_medicines" # médicaments de A à Z (NHS)
    "zimit/medlineplus.gov_en_all" # fiches santé grand public (NIH)
    "other/mdwiki_en_all_maxi" # encyclopédie médicale (WikiProjectMed)
  ];

  medicDocs = pkgs.writeShellScriptBin "epiviosi-medic-docs" ''
    # Télécharge la documentation médicale dans /wiki (EPIVÍOSI WIKI).
    # Options transmises à epiviosi-wiki-fetch (ex. --dry-run).
    exec epiviosi-wiki-fetch "$@" ${lib.escapeShellArgs docs}
  '';

  guide = pkgs.writeShellScriptBin "epiviosi-medic" ''
    exec firefox file:///etc/epiviosi/medic/guide.html
  '';

  guideItem = pkgs.makeDesktopItem {
    name = "epiviosi-medic";
    desktopName = "EPIVÍOSI MEDIC";
    genericName = "Guide médical";
    comment = "Numéros d'urgence, documentation médicale hors-ligne, dossiers chiffrés";
    exec = "epiviosi-medic";
    icon = "applications-science";
    categories = [
      "Education"
      "MedicalSoftware"
    ];
    keywords = [
      "médecine"
      "santé"
      "secours"
      "urgence"
      "medical"
    ];
  };

  dossiersItem = pkgs.makeDesktopItem {
    name = "epiviosi-medic-dossiers";
    desktopName = "Dossiers médicaux";
    genericName = "Coffre chiffré";
    comment = "Ouvrir ou verrouiller le coffre chiffré des dossiers médicaux";
    exec = "epiviosi-medic-dossiers";
    icon = "folder-locked";
    categories = [
      "Office"
      "MedicalSoftware"
    ];
  };
in
{
  config = lib.mkIf cfg.enable {
    environment.etc."epiviosi/medic/guide.html".source = ./assets/guide.html;

    environment.systemPackages = [
      coffre
      guide
      guideItem
      dossiersItem
    ]
    ++ lib.optional config.epiviosi.wiki.enable medicDocs;
  };
}
