smaster=`head -1 /opt/cluster-info.txt | cut -d "=" -f2`


echo $smaster
sed -i 's/sparkmaster/'$smaster'/g' /etc/ganglia/gmetad.conf
sed -i 's/sparkmaster/'$smaster'/g' /etc/ganglia/gmond.conf
sed -i 's/sparkmaster/'$smaster'/g' /usr/local/hadoop/etc/hadoop/hadoop-metrics2.properties
sed -i 's/sparkmaster/'$smaster'/g' /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/metrics.properties
#sed -i 's/10.0.1.128/sparkmaster/g' /etc/ganglia/gmetad.conf
#sed -i 's/10.0.1.128/sparkmaster/g' /etc/ganglia/gmond.conf
#sed -i 's/10.0.1.128/sparkmaster/g' /usr/local/hadoop/etc/hadoop/hadoop-metrics2.properties
#sed -i 's/10.0.1.128/sparkmaster/g' /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/metrics.properties

cp /etc/ganglia/gmond.conf /etc/ganglia/slave-gmond.conf
sed -i 's/deaf = no/deaf = yes/g' /etc/ganglia/slave-gmond.conf
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
        scp /etc/ganglia/slave-gmond.conf $ip:/etc/ganglia/gmond.conf
        scp /usr/local/hadoop/etc/hadoop/hadoop-metrics2.properties $ip:/usr/local/hadoop/etc/hadoop/hadoop-metrics2.properties
        scp /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/metrics.properties $ip:/usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/metrics.properties

        echo $ip $name $?
fi
done < "$file"
mv /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/metrics.properties /usr/local/spark-1.6.1-bin-custom-spark-final-1.6/conf/old_metrics.properties
#
