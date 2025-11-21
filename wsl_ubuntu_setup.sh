#!/usr/bin/env bash
set -e

# Einfaches Install-Skript für Ubuntu 24 (auch WSL)
# Mit Whiptail-Checkliste zum Abhaken, was installiert werden soll.

# --- VORAUSSETZUNG: whiptail ---
if ! command -v whiptail >/dev/null 2>&1; then
    echo "whiptail ist nicht installiert. Bitte einmal ausführen:"
    echo "  sudo apt update && sudo apt install whiptail"
    exit 1
fi

# --- OPTIONEN DEFINIEREN ---
# Tag  Beschreibung                                   Default
OPTIONS=(
  "python3"        "Python 3 Interpreter"              ON
  "python3-pip"    "Pip für Python 3"                  ON
  "python3-venv"   "Python venv-Modul"                 ON
  "git"            "Git Versionsverwaltung"            ON
  "vim"            "Vim Editor"                        OFF
  "vifm"           "VIFM Dateimanager (ncurses)"       OFF
  "ranger"         "Ranger Dateimanager (ncurses)"     OFF
  "nodejs"         "Node.js (apt-Version) + npm"       OFF
  "pm2"            "PM2 (Node Process Manager via npm)" OFF
  "qml5"           "Qt5/QML Basisentwicklung"          OFF
  "qml6"           "Qt6/QML Basisentwicklung"          OFF
)

# --- CHECKLIST DIALOG ---
CHOICES=$(whiptail --title "Ubuntu 24 Entwicklungs-Setup" \
  --checklist "Wähle die Komponenten, die installiert werden sollen:" \
  20 78 12 \
  "${OPTIONS[@]}" \
  3>&1 1>&2 2>&3) || {
    echo "Abgebrochen."
    exit 1
}

# Whiptail gibt etwas wie: "python3" "git" "nodejs"
# Anführungszeichen entfernen:
CHOICES_CLEAN=$(echo "$CHOICES" | sed 's/"//g')

if [ -z "$CHOICES_CLEAN" ]; then
    echo "Keine Auswahl getroffen. Beende."
    exit 0
fi

echo "Du hast ausgewählt: $CHOICES_CLEAN"
echo

# --- apt update nur einmal ---
echo "Führe sudo apt update aus..."
sudo apt update

APT_INSTALL_LIST=()
RUN_PM2_SETUP=false

# --- AUSWAHL IN PAKETE MAPPEN ---
for choice in $CHOICES_CLEAN; do
    case "$choice" in
        python3)
            APT_INSTALL_LIST+=(python3)
            ;;
        python3-pip)
            APT_INSTALL_LIST+=(python3-pip)
            ;;
        python3-venv)
            APT_INSTALL_LIST+=(python3-venv)
            ;;
        git)
            APT_INSTALL_LIST+=(git)
            ;;
        vim)
            APT_INSTALL_LIST+=(vim)
            ;;
        vifm)
            APT_INSTALL_LIST+=(vifm)
            ;;
        ranger)
            APT_INSTALL_LIST+=(ranger)
            ;;
        nodejs)
            # einfache Node.js-Installation aus Ubuntu-Repo
            APT_INSTALL_LIST+=(nodejs npm)
            ;;
        pm2)
            # pm2 lieber via npm global installieren
            RUN_PM2_SETUP=true
            ;;
        qml5)
            # Qt5/QML grobes Basis-Setup (kannst du anpassen)
            APT_INSTALL_LIST+=(qtbase5-dev qt5-qmake qt5-qmltooling-plugins qt5-quick-demos qml)
            ;;
        qml6)
            # Qt6/QML grobes Basis-Setup (kannst du anpassen)
            APT_INSTALL_LIST+=(qt6-base-dev qt6-declarative-dev qml-qt6 qml6-module-qtquick-controls)
            ;;
        *)
            echo "Unbekannte Auswahl: $choice (ignoriere)"
            ;;
    esac
done

# --- apt install ausführen ---
if [ "${#APT_INSTALL_LIST[@]}" -gt 0 ]; then
    echo
    echo "Installiere mit apt:"
    printf '  %s\n' "${APT_INSTALL_LIST[@]}"
    echo

    sudo apt install -y "${APT_INSTALL_LIST[@]}"
else
    echo "Keine apt-Pakete zu installieren."
fi

# --- PM2 Setup, falls gewählt ---
if [ "$RUN_PM2_SETUP" = true ]; then
    echo
    echo "PM2 wird via npm global installiert..."
    # Node.js + npm muss dafür vorhanden sein:
    if ! command -v npm >/dev/null 2>&1; then
        echo "npm wurde nicht gefunden. Bitte Node.js/npm installieren (z.B. über die Option 'nodejs')."
    else
        sudo npm install -g pm2
        echo "PM2 installiert. Du kannst z.B. 'pm2 list' ausführen."
    fi
fi


echo
echo "Fertig. Viel Spaß beim Entwickeln :)"

