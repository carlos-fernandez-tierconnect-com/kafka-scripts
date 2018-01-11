#! /bin/bash

#================================================================
#% DESCRIPTION
#% 
#================================================================

VIZIX_HOME=/home/cfernandez/src/mojix/riot

echo "Starting vizix deploy..."
echo $VIZIX_HOME

BRANCH=${1:-develop}  
CONTAINER_SUFIX=${2:-develop}
echo $BRANCH

# building services
echo "building services..."
cd $VIZIX_HOME/riot-core-services
pwd
git checkout $BRANCH
git pull
git status
gradle clean dist -x customFindbugs
gradle publish
echo "Finished services..."
#echo

sleep 5

# building bridges
echo "building bridges..."
cd $VIZIX_HOME/riot-core-bridges
pwd
git checkout $BRANCH
git pull
git status
gradle clean dist -x customFindbugs
echo "Finished bridges..."

# administrate docker containers


# executing popdb
echo "Eecuting popdb..."
cd $VIZIX_HOME/riot-core-services
pwd
gradle popdb
echo
echo "Finished popdb..."

# executing UI
echo "Eecuting UI..."
cd $VIZIX_HOME/riot-core-ui
pwd
git checkout $BRANCH
git pull
grunt serve > /tmp/riot-core-ui.log &
echo
echo "Finished UI..."

echo
echo "Finish deploy branch ${BRANCH}"

