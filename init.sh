#! /bin/bash

DOCKER_COMPOSE_HOME=/home/cfernandez/docker/vizix

VERSION=${1:-dev/7.x.x}
echo "version: "$VERSION
IMAGE="${VERSION/\//_}"
echo "image: "$IMAGE

echo "Starting envrinment | version: $VERSION"

cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
docker-compose down

docker-compose up -d kafka
docker-compose up -d mysql
docker-compose up -d mongo

VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$IMAGE docker-compose up -d services

#VIZIX_REPORTS="mojix/vizix-reports:"$VERSION docker-compose up -d reports
VIZIX_REPORTS="gcr.io/mojix-registry/vizix-reports:"$IMAGE docker-compose up -d reports                         

# consul is necessary for bridges starting in version 7.8.1
docker-compose up -d consul
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d moits
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d rp
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d tb
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d fa
#VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d hb

docker-compose up -d proxy
VIZIX_UI_IMAGE="mojix/riot-core-ui:"$IMAGE docker-compose up -d ui

#VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose up -d ett

echo
docker-compose ps
echo
echo "Environment started successfully | version: $VERSION"