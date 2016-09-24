rm /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/slaves
rm /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/spark-env.sh

cp /usr/local/hadoop/etc/hadoop/slaves /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/
smaster=`head -1 /opt/cluster-info.txt | cut -d "=" -f2`

sudo /bin/cat <<EOM >> /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/spark-env.sh
export SPARK_MASTER_IP=$smaster
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=1g
export SPARK_WORKER_INSTANCES=1
EOM


# Get the IP address of A, B , C nodes i.e., Parent and Child IP's
i=0
file="/opt/cluster-info.txt"
while IFS= read -r line
do
if [ $i == 0 ];
then
        #skipping first line
        i=1;
else
        name=`echo $line | cut -d "=" -f1`
        ip=`echo $line | cut -d "=" -f2`
        scp /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/spark-env.sh $ip:/usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/

        scp /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/slaves $ip:/usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/

        echo $ip $name $?

fi
done < "$file"

sudo /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/sbin/stop-all.sh
sudo /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/sbin/start-all.sh

# Ganglia Server Related
rm -fr /var/lib/ganglia/rrds/spark/*
sudo service ganglia-monitor restart && sudo service gmetad restart && sudo service apache2 restart

# Ganglia Slaves Related
function slave_ganglia_setup()
{
	sudo service ganglia-monitor restart
}

i=0
file="/opt/cluster-info.txt"
while IFS= read -r line
do
if [ $i == 0 ];
then
        #skipping first line
        i=1;
else
        name=`echo $line | cut -d "=" -f1`
        ip=`echo $line | cut -d "=" -f2`
    	ssh -tt $ip "$(typeset -f);slave_ganglia_setup"&
        echo $ip $name $?

fi
done < "$file"
