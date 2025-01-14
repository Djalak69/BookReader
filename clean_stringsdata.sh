#!/bin/bash

# Chemin vers le dossier DerivedData
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"

# Trouver le dossier du projet BookReader
PROJECT_FOLDER=$(find "$DERIVED_DATA_PATH" -name "BookReader-*" -type d)

if [ -n "$PROJECT_FOLDER" ]; then
    echo "Nettoyage des fichiers stringsdata..."
    find "$PROJECT_FOLDER" -name "*.stringsdata" -type f -delete
    echo "Nettoyage terminé"
else
    echo "Dossier du projet non trouvé"
fi 