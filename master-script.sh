#!/bin/bash

function Host_stuff()
{
source demo-openrc.sh

NUM=$1

count=0

echo '-------------Spinning up VMs-------------------'

while [ $count -lt $NUM ]; do

echo 'slave'$count

curl -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "username: admin_team1" --header "password: jedimindtricks" -d "{
  \"image_id\": \"f4c38985-6106-4311-9bd1-add9e6095686\",
  \"is_boot_from_volume\": false,
  \"name\": \"slave$count\",
  \"network_name\": \"network_team1\",
  \"security_group_name\": \"secgroup_team1\",
  \"security_key_name\": \"raunaq_temp\",
  \"specification_id\": \"2\",
  \"volume_name\": \"Boot_Volume_1\",
  \"volume_size\": 10,
  \"volume_type\": \"spindle\",
  \"zone\": \"nova\"
}" "http://transcirrus-1.oscar.priv:6969/v1.0/ccc4bd3570d14bc2a19cda28ccc1d34a/instances"

((count++))

done

rm cluster-info.txt
echo '-------------Getting IPs----------------------'

count=0

nova list |sed -n "/masterclean/p"| cut -d'=' -f2 | echo 'masterclean='`cut -d',' -f1` > cluster-info.txt

while [ $count -lt $NUM ]; do

echo 'Slave'$count

#nova list |sed -n "/Slave$count/p"| cut -d'=' -f2 | echo "Slave$count="`cut -d',' -f1` >> cluster-info.txt
#nova list |sed -n "/Slave$count/p"| cut -d'=' -f2 | echo "Slave$count="`cut -d'|' -f1` >> cluster-info.txt
IP=`nova list | grep "slave$count" | cut -d "|" -f 7 | cut -d " " -f2 | cut -d "=" -f 2 | tr -d ","`
echo "slave$count=$IP" >> cluster-info.txt

((count++))

done

nova list

sed -n "/^$/d" cluster-info.txt

exit
}

sudo ssh -tt 10.23.1.2 -l team1 "$(typeset -f);Host_stuff $1"
sudo scp team1@10.23.1.2:/home/team1/cluster-info.txt /opt/
#sudo less /opt/cluster-info.txt
