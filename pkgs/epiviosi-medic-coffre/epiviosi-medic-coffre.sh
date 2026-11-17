# epiviosi-medic-coffre — coffre chiffré « Dossiers médicaux » (gocryptfs).
#
# Usage : epiviosi-medic-coffre {creer|ouvrir|fermer|etat}
#   creer  : crée le coffre (phrase de passe lue sur l'entrée standard)
#            et y dépose les modèles de fiches ;
#   ouvrir : déverrouille le coffre dans ~/Dossiers-médicaux
#            (phrase de passe lue sur l'entrée standard) ;
#   fermer : verrouille le coffre ;
#   etat   : affiche « absent », « ferme » ou « ouvert ».
#
# Le coffre chiffré est rangé dans ~/Persistant (partition de persistance) ;
# sans persistance, dans ~/.dossiers-medicaux, perdu au redémarrage.
# EPIVIOSI_MEDIC_MODELES : dossier des modèles (fourni par le paquet).

die() { echo "Erreur : $*" >&2; exit 1; }

if [ -d "$HOME/Persistant" ]; then
  coffre="$HOME/Persistant/.dossiers-medicaux"
else
  coffre="$HOME/.dossiers-medicaux"
fi
clair="$HOME/Dossiers-médicaux"

etat() {
  if mountpoint -q "$clair"; then echo ouvert
  elif [ -f "$coffre/gocryptfs.conf" ]; then echo ferme
  else echo absent
  fi
}

lire_phrase() {
  IFS= read -r phrase || true
  [ -n "${phrase:-}" ] || die "phrase de passe vide."
}

case "${1:-}" in
  etat)
    etat
    ;;
  creer)
    [ "$(etat)" = absent ] || die "le coffre existe déjà ($coffre)."
    lire_phrase
    [ "${#phrase}" -ge 8 ] || die "phrase de passe trop courte (8 caractères minimum)."
    mkdir -p "$coffre" "$clair"
    gocryptfs -init -q -passfile <(printf '%s\n' "$phrase") "$coffre" >/dev/null \
      || die "création du coffre impossible."
    gocryptfs -q -passfile <(printf '%s\n' "$phrase") "$coffre" "$clair" \
      || die "ouverture du coffre impossible."
    mkdir -p "$clair/Modèles"
    cp --no-preserve=mode "$EPIVIOSI_MEDIC_MODELES"/*.odt "$clair/Modèles/"
    echo "Coffre créé et ouvert : $clair"
    ;;
  ouvrir)
    case "$(etat)" in
      absent) die "aucun coffre ; créez-le d'abord." ;;
      ouvert) echo "Déjà ouvert : $clair"; exit 0 ;;
    esac
    lire_phrase
    mkdir -p "$clair"
    gocryptfs -q -passfile <(printf '%s\n' "$phrase") "$coffre" "$clair" 2>/dev/null \
      || die "phrase de passe incorrecte."
    echo "Ouvert : $clair"
    ;;
  fermer)
    [ "$(etat)" = ouvert ] || { echo "Déjà fermé."; exit 0; }
    fusermount -u "$clair" || die "fermeture impossible (un fichier est-il encore ouvert ?)."
    echo "Coffre verrouillé."
    ;;
  *)
    echo "Usage : epiviosi-medic-coffre {creer|ouvrir|fermer|etat}" >&2
    exit 1
    ;;
esac
