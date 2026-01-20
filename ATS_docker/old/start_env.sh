#!/bin/bash

source ./config.sh

cp ./config.sh ./docker_ats/tests/
cp ./fix_interface_name_ats.sh ./docker_ats/tests/

#export env_interface=${env_interface}

export env_ats_inet_mac=${env_ats_inet_mac}
export env_ats_lan_mac=${env_ats_lan_mac}


export env_ats_interface=${ats_interface}
export env_lan_interface=${lan_interface}



echo "host interface name"
echo "eth-inet binding host interface name: ${env_ats_interface}"
echo "eth-lan mac : ${env_ats_inet_mac}"
echo "eth-lan binding host interface name: ${env_lan_interface}"
echo "eth-lan mac : ${env_ats_lan_mac}"


echo "build env ats"
cd docker_ats
docker compose up -d
cd ..
