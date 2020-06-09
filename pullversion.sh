#! /bin/bash

#================================================================
#% DESCRIPTION
#% Install an specific version of ViZix
#================================================================

VIZIX_HOME=/home/cfernandez/src/mojix/vizix
DOCKER_COMPOSE_HOME=/home/cfernandez/docker/vizix
USER_PASSWORD=password

echo "Starting vizix deploy..."
echo $VIZIX_HOME

VERSION=${1:-v7.8.0}

echo $VERSION

# administrate docker containers
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }

VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$VERSION docker-compose pull services
VIZIX_REPORTS="mojix/vizix-reports:"$VERSION docker-compose pull reports
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose pull rg
VIZIX_UI_IMAGE="mojix/riot-core-ui:"$VERSION docker-compose pull ui