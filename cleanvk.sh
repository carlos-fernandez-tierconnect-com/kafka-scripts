#! /bin/bash

#================================================================
#% DESCRIPTION
#% This is an script to clean a kafka environment
#================================================================

KAFKA_HOME=/opt/kafka
VIZIX_SERVICES_HOME=/home/cfernandez/src/mojix/riot

echo $KAFKA_HOME

# stop kafka server and zookeeper
cd $KAFKA_HOME
pwd
echo "stopping kafka..."
bin/kafka-server-stop.sh
sleep 10

echo "stopping zookeeper..."
bin/zookeeper-server-stop.sh
sleep 5

# cleaning cache
echo "cleaning tmp cache..."
echo
rm -rf /tmp/kafka-logs
rm -rf /tmp/kafka.log
rm -rf /tmp/zookeeper
rm -rf /tmp/zookeeper.log
rm -rf /tmp/siteconfig
rm -rf /tmp/rp.log
rm -rf /tmp/moi.log
rm -rf /var/vizix/*
echo "end cleaning tmp data"

# start Kafka
pwd
echo
echo "starting zookeeper..."
bin/zookeeper-server-start.sh config/zookeeper.properties > /tmp/zookeeper.log &
sleep 10

echo
echo "starting kafka..."
bin/kafka-server-start.sh config/server.properties > /tmp/kafka.log &
sleep 10

read -p "have you finish to execute popdb manually ? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo    
fi

read -p "Do you want to populate kafka ? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd $VIZIX_SERVICES_HOME/riot-core-services
    pwd
    export VIZIX_HOME_SERVICES=$VIZIX_SERVICES_HOME/riot-core-services/build
    echo "VIZIX_HOME_SERVICES: ${VIZIX_HOME_SERVICES}"
    ./kafkaTopicTool.sh -c
    ./kafkaCacheLoader.sh

    #updating APIKEY
    #mysql -h mysql -u root -pcontrol123! riot_name < apikey.sql
    echo
	read APIKEY <<< $(mysql -Driot_main -uroot -pcontrol123! -h 127.0.0.1 -se 'select apikey from VIZ_APC_USER where username="root"')
	echo "APIKEY GENERATED: ${APIKEY}"
	export VIZIX_API_KEY=$APIKEY
	echo $VIZIX_API_KEY
	echo

    ./write-siteconfig.sh
    ./kafkaCacheLoader.sh -d /tmp/siteconfig -pk
fi

echo "Kafka installation script finished"


