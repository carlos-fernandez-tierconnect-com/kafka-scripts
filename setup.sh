#! /bin/bash

#================================================================
#% DESCRIPTION
#% Install an specific version of ViZix
#================================================================

VIZIX_HOME=/home/cfernandez/src/mojix/riot
DOCKER_COMPOSE_HOME=/home/cfernandez/Documents/docker/kafka2

echo "Starting vizix deploy..."
echo $VIZIX_HOME

VERSION=${1:-v6.72.11}

echo $VERSION

# administrate docker containers
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
docker-compose down

# Preparing sysconfig
echo "Removing volumes..."
cd $DOCKER_COMPOSE_HOME/volume || { echo "Cannot find volume directory"; exit 1; }
echo "password" | sudo -S rm -rf kafka zookeper mysql vizix
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
docker-compose up -d kafka
docker-compose up -d mysql
docker-compose up -d mongo

# Start vizix-tools executiion
cd $DOCKER_COMPOSE_HOME/volume/tools/sysconfig || { echo "Cannot find volume/tools/sysconfig directory"; exit 1; }
echo "password" | sudo -S rm -rf *
ls -l

echo "Getting sysconfig files version: "$VERSION
cd $VIZIX_HOME/riot-core-sysconfig || { echo "Cannot find VIZIX_HOME/riot-core-sysconfig directory"; exit 1; }
git checkout dev/7.x.x
git branch -D temp_$VERSION
git fetch --all --tags
git checkout tags/$VERSION -b temp_$VERSION
ls -l
echo "password" | sudo -S cp -R * $DOCKER_COMPOSE_HOME/volume/tools/sysconfig

cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
VIZIX_TOOLS_IMAGE="mojix/vizix-tools:"$VERSION docker-compose pull tools
VIZIX_TOOLS_IMAGE="mojix/vizix-tools:"$VERSION docker-compose up tools
# End vizix-tools executiion

VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$VERSION docker-compose pull services
VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$VERSION docker-compose up -d services

VIZIX_REPORTS="mojix/riot-core-reports:"$VERSION docker-compose pull reports
VIZIX_REPORTS="mojix/riot-core-reports:"$VERSION docker-compose up -d reports

VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose pull rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d moits
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d rp
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d tb
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d fa
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$VERSION docker-compose up -d hb

VIZIX_UI_IMAGE="mojix/riot-core-ui:"$VERSION docker-compose pull ui
VIZIX_UI_IMAGE="mojix/riot-core-ui:"$VERSION docker-compose up -d ui

VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose pull ett
VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose up -d ett

echo
docker-compose ps
echo
echo "Deploy finished successfully | version: $VERSION"

