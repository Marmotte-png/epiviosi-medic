# epiviosi-medic-dossiers — interface graphique du coffre « Dossiers médicaux ».

titre="Dossiers médicaux — EPIVÍOSI MEDIC"
clair="$HOME/Dossiers-médicaux"

erreur() { zenity --error --title="$titre" --width=380 --text="$1"; }

case "$(epiviosi-medic-coffre etat)" in
  ouvert)
    if zenity --question --title="$titre" --width=380 \
         --ok-label="Verrouiller" --cancel-label="Afficher" \
         --text="Le coffre est ouvert.\n\nLe verrouiller maintenant ?"; then
      msg="$(epiviosi-medic-coffre fermer 2>&1)" || { erreur "$msg"; exit 1; }
      zenity --info --title="$titre" --width=300 --text="Coffre verrouillé."
    else
      xdg-open "$clair"
    fi
    ;;
  ferme)
    phrase="$(zenity --password --title="$titre")" || exit 0
    msg="$(printf '%s\n' "$phrase" | epiviosi-medic-coffre ouvrir 2>&1)" || { erreur "$msg"; exit 1; }
    xdg-open "$clair"
    ;;
  absent)
    if [ ! -d "$HOME/Persistant" ]; then
      zenity --question --title="$titre" --width=420 --ok-label="Continuer" --cancel-label="Annuler" \
        --text="Aucune partition de persistance : les dossiers seront <b>perdus au redémarrage</b>.\n\nPour les conserver : <tt>sudo epiviosi-persist-setup</tt>, puis redémarrer." \
        || exit 0
    fi
    zenity --info --title="$titre" --width=420 \
      --text="Création du coffre chiffré.\n\nChoisissez une phrase de passe longue (plusieurs mots). <b>Sans elle, les dossiers sont irrécupérables.</b>" || exit 0
    p1="$(zenity --password --title="Nouvelle phrase de passe")" || exit 0
    p2="$(zenity --password --title="Confirmer la phrase de passe")" || exit 0
    [ "$p1" = "$p2" ] || { erreur "Les deux phrases de passe sont différentes."; exit 1; }
    msg="$(printf '%s\n' "$p1" | epiviosi-medic-coffre creer 2>&1)" || { erreur "$msg"; exit 1; }
    xdg-open "$clair"
    ;;
esac
