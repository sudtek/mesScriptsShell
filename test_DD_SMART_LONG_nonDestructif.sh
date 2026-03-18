#!/bin/bash

# Script : test_DD_SMART_LONG_nonDestructif.sh
# Usage  : sudo ./test_DD_SMART_LONG_nonDestructif.sh


# 11 mars 2026 yannick SUDRIE
#
# Script non destructif pour les données pour tester un disque dur.
# Idéal pour tester un disque neuf avant de créer une partition. 
# Attention un dsique dur de taille 24T requier environ 30 heures pour réalisé 100% du test via un interface SATA qui débite à 200Mb/s .. 250Mbs


# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier les droits root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Ce script doit être exécuté en tant que root (sudo).${NC}"
   exit 1
fi

# Vérifier que smartctl est installé
if ! command -v smartctl &> /dev/null; then
    echo -e "${YELLOW}smartctl n'est pas installé. Installation de smartmontools...${NC}"
    apt update && apt install -y smartmontools
    if [ $? -ne 0 ]; then
        echo -e "${RED}Échec de l'installation. Installez smartmontools manuellement.${NC}"
        exit 1
    fi
fi

# Fonction pour lister les disques
list_disks() {
    echo -e "${GREEN}Disques détectés :${NC}"
    lsblk -d -o NAME,SIZE,MODEL | grep -E "^(sd|hd|vd|nvme)"
}

# Boucle de sélection
while true; do
    list_disks
    echo ""
    read -p "Entrez le nom du disque à tester (ex: sda, nvme0n1) : " disk
    if [[ -z "$disk" ]]; then
        echo -e "${RED}Saisie vide.${NC}"
        continue
    fi
    if [[ ! -e "/dev/$disk" ]]; then
        echo -e "${RED}/dev/$disk n'existe pas.${NC}"
        continue
    fi
    break
done

# Dernière confirmation
echo ""
echo -e "${YELLOW}Vous allez lancer un test SMART LONG sur /dev/$disk.${NC}"
echo "Ce test peut durer plusieurs dizaines d'heures (lecture seule, sans risque pour les données)."
read -p "Tapez 'yes' pour confirmer : " confirm
if [[ "$confirm" != "yes" ]]; then
    echo -e "${RED}Abandon.${NC}"
    exit 0
fi

# Lancer le test
echo -e "${GREEN}Lancement du test SMART long sur /dev/$disk...${NC}"
smartctl -t long /dev/$disk



# Afficher comment suivre la progression
echo ""
echo " A propos du disque ${disk} "
sudo smartctl -a /dev/$disk
echo " ---------------------------------------------------------------------------------- "
echo -e "${GREEN}Test lancé. Pour suivre la progression :${NC}"
echo "  watch -n 60 "sudo smartctl -a /dev/sdb | grep -i 'self-test'""
echo "  ou sudo smartctl -a /dev/$disk pour avoir toutes les informations du disque"
echo "  ou attendre la fin et vérifier les erreurs : sudo smartctl -l selftest /dev/$disk"
echo " ---------------------------------------------------------------------------------- "
echo ""
echo ""

read -n 1 -s -r -p "Appuyer sur une touche pour lancer le suivi de la progression du test SMART LONG"

# Suivi de la progression du test SMART LONG toute les 60s
echo ""
echo ""
watch -n 10 "sudo smartctl -a /dev/$disk | grep -i 'self-test'"
