#! /bin/bash

VERSION=${1:-v7.4.0}
DOCKER_COMPOSE_HOME=/home/cfernandez/Documents/docker/kafka2

echo "Shutdwon envrinment | version: $VERSION"

cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }

VIZIX_UI_IMAGE="mojix/riot-core-ui:"$VERSION docker-compose stop ui

VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose stop ett

VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$VERSION docker-compose stop services

VIZIX_REPORTS="mojix/riot-core-reports:"$VERSION docker-compose stop reports

VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose stop rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose stop moits
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose stop rp
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose stop tb
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose stop fa
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose stop hb

docker-compose stop kafka
docker-compose stop zoo
docker-compose stop mysql
docker-compose stop mongo

echo
docker-compose ps
echo
echo "Shutdown executed successfully | version: $VERSION"