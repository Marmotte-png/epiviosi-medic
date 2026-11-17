# Test NixOS du module EPIVÍOSI MEDIC : guide et lanceurs installés, coffre
# chiffré (création, contenu illisible une fois verrouillé, mauvaise phrase
# refusée, réouverture), modèles de fiches présents.
{ pkgs, module }:
pkgs.testers.runNixOSTest {
  name = "epiviosi-medic";

  nodes.machine =
    { lib, ... }:
    {
      imports = [ module ];
      # Options normalement déclarées par le socle EPIVÍOSI OS.
      options.epiviosi = {
        user = lib.mkOption {
          type = lib.types.str;
          default = "epiviosi";
        };
        medic.enable = lib.mkEnableOption "EPIVÍOSI MEDIC";
        wiki.enable = lib.mkEnableOption "EPIVÍOSI WIKI";
      };
      config = {
        epiviosi.medic.enable = true;
        epiviosi.wiki.enable = true;
        users.users.epiviosi.isNormalUser = true;
      };
    };

  testScript = ''
    def u(cmd):
        return machine.succeed(f"su - epiviosi -c \"{cmd}\"")

    def u_fail(cmd):
        machine.fail(f"su - epiviosi -c \"{cmd}\"")

    machine.wait_for_unit("multi-user.target")

    with subtest("guide, lanceurs et docs installés"):
        for cmd in ["epiviosi-medic", "epiviosi-medic-dossiers", "epiviosi-medic-coffre", "epiviosi-medic-docs"]:
            machine.succeed(f"command -v {cmd}")
        machine.succeed("test -s /etc/epiviosi/medic/guide.html")
        for d in ["epiviosi-medic", "epiviosi-medic-dossiers"]:
            machine.succeed(f"test -f /run/current-system/sw/share/applications/{d}.desktop")
        machine.succeed("grep -q mdwiki_en_all_maxi $(command -v epiviosi-medic-docs)")

    with subtest("persistance simulée : coffre dans ~/Persistant"):
        u("mkdir -p ~/Persistant")
        assert u("epiviosi-medic-coffre etat").strip() == "absent"
        u_fail("echo court | epiviosi-medic-coffre creer")

    with subtest("création : modèles déposés, fiche enregistrée"):
        u("echo 'cheval batterie agrafe' | epiviosi-medic-coffre creer")
        assert u("epiviosi-medic-coffre etat").strip() == "ouvert"
        for f in ["fiche-patient", "bilan-secouriste", "suivi-traitement"]:
            u(f"test -s ~/Dossiers-médicaux/Modèles/{f}.odt")
        u("echo 'Allergie : pénicilline' > ~/Dossiers-médicaux/dupont.txt")

    with subtest("verrouillé : contenu chiffré, illisible"):
        u("epiviosi-medic-coffre fermer")
        assert u("epiviosi-medic-coffre etat").strip() == "ferme"
        u("test ! -e ~/Dossiers-médicaux/dupont.txt")
        u("test -f ~/Persistant/.dossiers-medicaux/gocryptfs.conf")
        machine.fail("grep -r -a -q pénicilline /home/epiviosi/Persistant/.dossiers-medicaux")

    with subtest("mauvaise phrase refusée, bonne phrase acceptée"):
        u_fail("echo 'mauvaise phrase' | epiviosi-medic-coffre ouvrir")
        assert u("epiviosi-medic-coffre etat").strip() == "ferme"
        u("echo 'cheval batterie agrafe' | epiviosi-medic-coffre ouvrir")
        u("grep -q pénicilline ~/Dossiers-médicaux/dupont.txt")
        u("epiviosi-medic-coffre fermer")
  '';
}
