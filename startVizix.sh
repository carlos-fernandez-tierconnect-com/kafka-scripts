#! /bin/bash

#================================================================
#% DESCRIPTION
#% 
#================================================================

VIZIX_HOME=/home/cfernandez/src/mojix/riot
DOCKER_COMPOSE_HOME=/home/cfernandez/Documents/docker/kafka2

echo "Starting vizix deploy..."
echo $VIZIX_HOME

BRANCH=${1:-canary/6.72.x}
CONTAINER_SUFIX=${2:-develop}
echo $BRANCH

# building commons
echo "######################## [start build | riot-core-commons]"
echo
cd $VIZIX_HOME/riot-core-commons || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
pwd
git stash
git checkout $BRANCH
git pull
git status
gradle clean assemble publish
echo "######################## [end build | riot-core-commons]"
echo

# building services
echo "######################## [start build | riot-core-services]"
echo
cd $VIZIX_HOME/riot-core-services || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
pwd
git stash
git checkout $BRANCH
git pull
git status
gradle clean dist publish -x test -x customFindbugs && rm -rf app && mkdir -p app && unzip build/libs/riot-core-services.war -d app && docker build -t vizix-services . && docker build -f DockerfileInstaller -t vizix-tools .
echo "######################## [end build | riot-core-services]"
echo

sleep 5

# building bridges
echo "######################## [start build | riot-core-bridges]"
echo
cd $VIZIX_HOME/riot-core-bridges || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
pwd
git stash
git checkout $BRANCH
git pull
git status
gradle clean && gradle gitversion && gradle dist -x customFindbugs -x test && rm -rf app && mkdir -p app && docker build -t vizix-bridges .
echo "######################## [end build | riot-core-bridges]"
echo

# administrate docker containers
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }
pwd

docker-compose down

# Preparing sysconfig
cd $DOCKER_COMPOSE_HOME/volume || { echo "Cannot find volume directory"; exit 1; }
echo "fernandez1985" | sudo -S rm -rf kafka zookeper mysql
cd $DOCKER_COMPOSE_HOME || { echo "Cannot find DOCKER_COMPOSE_HOME directory"; exit 1; }

docker-compose up -d kafka
docker-compose up -d mysql
docker-compose up -d mongo

# Executing sysconfig
docker-compose up tools
docker-commons up -d services
docker-commons up -d rg
docker-commons up -d moits
docker-commons up -d rp
docker-commons up -d tb
docker-commons up -d fa
docker-commons up -d hb

docker-commons pull ui && docker-commons up -d ui

# executing popdb
#echo "Eecuting popdb..."
#cd $VIZIX_HOME/riot-core-services
#pwd
#gradle sysconfig
#echo
#echo "Finished popdb..."

# executing UI
#echo "Eecuting UI..."
#cd $VIZIX_HOME/riot-core-ui
#pwd
#git checkout $BRANCH
#git pull
#grunt serve > /tmp/riot-core-ui.log &
#echo
#echo "Finished UI..."

echo
echo "Finish deploy branch ${BRANCH}"

