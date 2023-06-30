#!/bin/bash

# Vérifier si l'URL GitHub a été fournie en argument
if [ -z "$1" ]; then
  echo "Veuillez fournir l'URL GitHub du projet."
  exit 1
fi

# Cloner le projet depuis l'URL GitHub fournie
git clone "$1" myproject
cd myproject

# Vérifier les dépendances système
if ! command -v php >/dev/null 2>&1; then
  echo "PHP n'est pas installé. Veuillez installer PHP 8+."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker n'est pas installé. Veuillez installer Docker."
  exit 1
fi

if ! command -v composer >/dev/null 2>&1; then
  echo "Composer n'est pas installé. Veuillez installer Composer 2.0+."
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js n'est pas installé. Veuillez installer Node.js v17+."
  exit 1
fi

# Installer les dépendances avec Composer
docker run --rm --interactive --tty \
  --volume $PWD:/app \
  composer install --ignore-platform-reqs

# Copier le fichier .env.example
cp .env.example .env

# Installer les dépendances avec npm
npm install

# Démarrer le conteneur Docker
./vendor/bin/sail up -d

# Exécuter les migrations et les seeders de la base de données
./vendor/bin/sail artisan migrate:fresh --seed

# Optimiser les routes et les configurations
./vendor/bin/sail artisan optimize

# Compiler les assets
npm run dev
