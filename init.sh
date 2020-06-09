#! /bin/bash

VERSION=${1:-v7.8.0}
DOCKER_COMPOSE_HOME=/home/cfernandez/docker/vizix

echo "Starting envrinment | version: $VERSION"

cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
docker-compose down

docker-compose up -d kafka
docker-compose up -d mysql
docker-compose up -d mongo

VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$VERSION docker-compose up -d services

VIZIX_REPORTS="mojix/vizix-reports:"$VERSION docker-compose up -d reports

VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d moits
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d rp
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d tb
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d fa
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d hb

VIZIX_UI_IMAGE="mojix/riot-core-ui:"$VERSION docker-compose up -d ui

VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose up -d ett

echo
docker-compose ps
echo
echo "Environment started successfully | version: $VERSION"