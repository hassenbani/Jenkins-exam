FROM python:3.8-slim AS build

WORKDIR /app

# Copier d'abord les dépendances et installer les outils nécessaires
COPY ./requirements.txt /app/requirements.txt
RUN apt-get update \
    && apt-get install -y gcc \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && apt-get clean

# Copier l'application
COPY . /app/

# Installer trivy
FROM aquasec/trivy:latest AS trivy

# Exécuter le scan de vulnérabilité
RUN trivy rootfs --no-progress /

# Utiliser l'image de base pour l'application
FROM python:3.8-slim

WORKDIR /app

# Copier les fichiers de l'étape de build
COPY --from=build /app .

# Copier les résultats du scan de vulnérabilité
COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy

# Exécuter l'application
CMD ["python", "app.py"]

