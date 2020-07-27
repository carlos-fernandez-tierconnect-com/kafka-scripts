#! /bin/bash

#================================================================
#% DESCRIPTION
#% Install an specific version of ViZix
#================================================================

VIZIX_HOME=/home/cfernandez/src/mojix/vizix
DOCKER_COMPOSE_HOME=/home/cfernandez/docker/vizix
USER_PASSWORD=xxxxx

echo "Starting vizix deploy..."
echo $VIZIX_HOME

VERSION=${1:-dev/7.x.x}
echo "version: "$VERSION
IMAGE="${VERSION/\//_}"
echo "image: "$IMAGE

# administrate docker containers
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
docker-compose down
sleep 5

# Preparing sysconfig
echo "Removing volumes..."
cd $DOCKER_COMPOSE_HOME/volume || { echo "Cannot find volume directory"; exit 1; }
echo $USER_PASSWORD | sudo -S rm -rf kafka zookeper mysql vizix
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
docker-compose up -d kafka
docker-compose up -d mysql
docker-compose up -d mongo

# Start vizix-tools executiion
cd $DOCKER_COMPOSE_HOME/volume/tools/sysconfig || { echo "Cannot find volume/tools/sysconfig directory"; exit 1; }
echo $USER_PASSWORD| sudo -S rm -rf *
ls -l

echo "Getting sysconfig files version: "$VERSION
cd $VIZIX_HOME/riot-core-sysconfig || { echo "Cannot find VIZIX_HOME/riot-core-sysconfig directory"; exit 1; }
#git checkout $VERSION
git checkout feature/clean_cubes_regen
#git branch -D temp_$IMAGE
#git fetch --all --tags
#git checkout tags/$VERSION -b temp_$IMAGE
ls -l
echo $USER_PASSWORD | sudo -S cp -R * $DOCKER_COMPOSE_HOME/volume/tools/sysconfig

cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
#VIZIX_TOOLS_IMAGE="mojix/vizix-tools:"$IMAGE docker-compose pull tools
#VIZIX_TOOLS_IMAGE="mojix/vizix-tools:"$IMAGE docker-compose up tools
VIZIX_TOOLS_IMAGE="gcr.io/mojix-registry/retail-tools:"$IMAGE docker-compose pull tools
VIZIX_TOOLS_IMAGE="gcr.io/mojix-registry/retail-tools:"$IMAGE docker-compose up tools

read -p "does sysconfig run successfully ? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "continue installation...."
fi
# End vizix-tools execution

VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$IMAGE docker-compose pull services
VIZIX_SERVICES_IMAGE="mojix/riot-core-services:"$IMAGE docker-compose up -d services

VIZIX_REPORTS="gcr.io/mojix-registry/vizix-reports:"$IMAGE docker-compose pull reports
VIZIX_REPORTS="gcr.io/mojix-registry/vizix-reports:"$IMAGE docker-compose up -d reports

# consul is necessary for bridges starting in version 7.8.1
docker-compose up -d consul

VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose pull rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d rg
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d moits
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d rp
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d tb
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d fa
VIZIX_BRIDGES_IMAGE="mojix/riot-core-bridges:"$IMAGE docker-compose up -d hb

docker-compose up -d proxy
VIZIX_UI_IMAGE="mojix/riot-core-ui:"$IMAGE docker-compose pull ui
VIZIX_UI_IMAGE="mojix/riot-core-ui:"$IMAGE docker-compose up -d ui

#VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose pull ett
#VIZIX_TRANSFOMER_IMAGE="mojix/vizix-api-transformer:"$VERSION docker-compose up -d ett

echo
docker-compose ps
echo
echo "Deploy finished successfully | version: $VERSION"

