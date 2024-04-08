FROM python:3.8-slim

WORKDIR /app

# Copier d'abord les dépendances et installer les outils nécessaires
COPY ./requirements.txt /app/requirements.txt
RUN apt-get update \
    && apt-get install -y gcc \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && apt-get clean

# Copier l'application et exécuter le scan de vulnérabilité
COPY ./app/ /app/
RUN apt-get update \
    && apt-get install -y curl \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && trivy --no-progress /app/

# Nettoyer le cache et l'installation des outils
RUN rm -rf /root/.cache/pip \
    && apt-get remove -y curl \
    && apt-get autoremove -y \
    && apt-get clean

# Commande par défaut pour l'exécution de l'application
CMD ["python", "app.py"]

