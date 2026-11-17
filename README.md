# EPIVÍOSI MEDIC

Documentation médicale et dossiers chiffrés, hors-ligne, pour
[EPIVÍOSI OS](https://github.com/Marmotte-png/epiviosi).

> Ces outils aident à comprendre, noter et transmettre. Ils ne remplacent ni un avis médical
> ni une formation aux premiers secours. Urgence : **15** (SAMU), **112** (Europe), **18**, **17**,
> **114** (SMS).

## Contenu

- **Guide « EPIVÍOSI MEDIC »** (menu) : numéros d'urgence, ressources, mode d'emploi des dossiers.
- **Dossiers médicaux** (menu) : coffre chiffré [gocryptfs](https://nuetzlich.net/gocryptfs/)
  rangé dans `~/Persistant/.dossiers-medicaux`, ouvert avec une phrase de passe dans
  `~/Dossiers-médicaux`. À la création, il reçoit des modèles LibreOffice : **fiche patient**,
  **bilan secouriste** (fiche d'intervention et surveillance) et **suivi de traitement**.
  Sans partition de persistance, le coffre est perdu au redémarrage (l'interface le signale).
- **`epiviosi-medic-docs`** : avec une connexion, ajoute à EPIVÍOSI WIKI ≈ 4,4 Go de
  documentation médicale (en anglais) :

| Archive | Contenu | Taille |
| --- | --- | --- |
| Medical Library (zimgit) | Manuels de premiers secours, « Where There Is No Doctor »… | ≈ 70 Mo |
| Military Medicine | Médecine de terrain, traumatismes | ≈ 65 Mo |
| NHS Medicines A–Z | Médicaments : usages, doses, effets indésirables | ≈ 15 Mo |
| MedlinePlus | Fiches maladies, examens, médicaments (NIH) | ≈ 1,9 Go |
| MDWiki | Encyclopédie médicale rédigée par des médecins | ≈ 2,3 Go |

La traduction de ces pages en français se fait dans Firefox, hors-ligne (socle EPIVÍOSI OS).

## Ligne de commande

```sh
echo 'phrase de passe' | epiviosi-medic-coffre creer    # crée et ouvre le coffre
echo 'phrase de passe' | epiviosi-medic-coffre ouvrir
epiviosi-medic-coffre fermer
epiviosi-medic-coffre etat                                # absent | ferme | ouvert
epiviosi-medic-docs --dry-run
```

## Utilisation dans un flake

Le module implémente l'option `epiviosi.medic.enable`, déclarée par le socle EPIVÍOSI OS :

```nix
inputs.epiviosi-medic = {
  url = "github:Marmotte-png/epiviosi-medic";
  inputs.nixpkgs.follows = "nixpkgs";
};
# …
modules = [ epiviosi-medic.nixosModules.default { epiviosi.medic.enable = true; } ];
```

## Tests

```sh
nix flake check                      # modèles, outil, test en VM (KVM dans le bac à sable Nix)
$(nix build --no-link --print-out-paths .#checks.x86_64-linux.vm.driver)/bin/nixos-test-driver
```

Le test crée le coffre, vérifie les modèles, enregistre une fiche, puis contrôle qu'une fois
verrouillé son contenu est introuvable en clair, qu'une mauvaise phrase de passe est refusée et
que la bonne rouvre le coffre.

## Structure

| Chemin | Rôle |
| --- | --- |
| `module.nix` | Module NixOS : guide, lanceurs, `epiviosi-medic-docs` |
| `pkgs/epiviosi-medic-coffre/` | Coffre chiffré (ligne de commande et interface zenity) |
| `templates/` | Modèles de fiches (HTML converti en ODT à la construction) |
| `assets/guide.html` | Guide EPIVÍOSI MEDIC (FR/EN) |
| `tests/medic.nix` | Test NixOS en VM |

## Licence

[Hippocratic License 2.1](LICENSE).
