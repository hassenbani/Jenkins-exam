FROM python:3.8-slim

WORKDIR /app

# Copier d'abord les dépendances et installer les outils nécessaires
COPY ./requirements.txt /app/requirements.txt
RUN apt-get update \
    && apt-get install -y gcc \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && apt-get clean

# Copier l'application
COPY ./app/ /app/

# Installer trivy
RUN apt-get update \
    && apt-get install -y curl \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && apt-get remove -y curl \
    && apt-get clean

# Exécuter le scan de vulnérabilité
RUN trivy /app

