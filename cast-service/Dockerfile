FROM python:3.8-slim

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN apt-get update \
    && apt-get install gcc -y \
    && apt-get clean
#Run vulnerability scan on build image
FROM build AS vulscan
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy rootfs --no-progress /

RUN pip install -r /app/requirements.txt \
    && rm -rf /root/.cache/pip
COPY ./app/
