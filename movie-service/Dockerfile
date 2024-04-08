# Utilisation de l'image Python 3.8 slim comme base
FROM python:3.8-slim AS build

# Définition du répertoire de travail dans le conteneur
WORKDIR /app

# Copie du fichier requirements.txt dans le répertoire de travail
COPY ./requirements.txt /app/requirements.txt

# Installation des dépendances et de gcc
RUN apt-get update \
    && apt-get install -y gcc \
    && apt-get clean

# Installation des dépendances Python
RUN pip install -r /app/requirements.txt \
    && rm -rf /root/.cache/pip

# Copie du reste du code source dans le répertoire de travail
COPY . /app/

# Définition d'une nouvelle étape pour le scan de vulnérabilité
FROM aquasec/trivy:latest AS vulnscan

# Copie de l'exécutable Trivy depuis l'image officielle
COPY --from=vulnscan /usr/local/bin/trivy /usr/local/bin/trivy

# Analyse de l'image avec Trivy pour détecter les vulnérabilités
RUN trivy --no-progress rootfs /

# Utilisation de l'image Python 3.8 slim comme base pour l'étape finale
FROM python:3.8-slim

# Copie des fichiers construits à partir de l'étape précédente
COPY --from=build /app /app

# Définition du répertoire de travail dans le conteneur
WORKDIR /app

# Commande par défaut pour l'exécution de l'application
CMD ["python", "app.py"]

