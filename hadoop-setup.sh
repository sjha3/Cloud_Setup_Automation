#!/bin/bash
cat "" > ~/.ssh/known_hosts
source /etc/profile
rm /etc/hosts
touch /etc/hosts
/bin/cat <<EOM >> /etc/hosts
127.0.0.1 localhost
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOM
sed -n '1p' /opt/cluster-info.txt > /opt/test1.txt
master_ip=$(cut -d'=' -f2 /opt/test1.txt)
master=$(cut -d'=' -f1 /opt/test1.txt)
rm -f /opt/test1.txt
echo "$master_ip $master" >> /etc/hosts
echo "$master" > /usr/local/hadoop/etc/hadoop/masters

rm -rf /usr/local/hadoop_tmp/namenode/current

rm /usr/local/hadoop/etc/hadoop/slaves
touch /usr/local/hadoop/etc/hadoop/slaves
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
  echo "$ip $name" >> /etc/hosts
        echo "$name" >> /usr/local/hadoop/etc/hadoop/slaves
        echo $ip $name
fi
done <"$file"


#sed -n '2p' /opt/cluster-info.txt > /opt/test2.txt
#slave1_ip=$(cut -d'=' -f2 /opt/test2.txt)
#slave1=$(cut -d'=' -f1 /opt/test2.txt)
#rm -f /opt/test2.txt
#echo "$slave1_ip $slave1" >> /etc/hosts
#echo "$slave1" >> /usr/local/hadoop/etc/hadoop/slaves



cd /usr/local/hadoop/etc/hadoop



cp /usr/local/hadoop/etc/hadoop/core-site.xml.template /usr/local/hadoop/etc/hadoop/core-site.xml
sudo grep -v "<configuration>" /usr/local/hadoop/etc/hadoop/core-site.xml > /usr/local/hadoop/etc/hadoop/temp.xml
sudo grep -v "</configuration>" /usr/local/hadoop/etc/hadoop/temp.xml > /usr/local/hadoop/etc/hadoop/core-site.xml
sudo /bin/cat <<EOM >> /usr/local/hadoop/etc/hadoop/core-site.xml
<configuration>
        <property>
                <name>fs.default.name</name>
                <value>hdfs://$master:9000</value>
        </property>
</configuration>
EOM
cp /usr/local/hadoop/etc/hadoop/hdfs-site.xml.template /usr/local/hadoop/etc/hadoop/hdfs-site.xml
sudo grep -v "<configuration>" /usr/local/hadoop/etc/hadoop/hdfs-site.xml > /usr/local/hadoop/etc/hadoop/temp.xml
sudo grep -v "</configuration>" /usr/local/hadoop/etc/hadoop/temp.xml > /usr/local/hadoop/etc/hadoop/hdfs-site.xml
sudo /bin/cat <<EOM >> /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<configuration>
        <property>
                <name>dfs.replication</name>
                <value>2</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:/usr/local/hadoop_tmp/hdfs/namenode</value>
        </property>
</configuration>
EOM
cp /usr/local/hadoop/etc/hadoop/yarn-site.xml.template /usr/local/hadoop/etc/hadoop/yarn-site.xml
sudo grep -v "<configuration>" /usr/local/hadoop/etc/hadoop/yarn-site.xml > /usr/local/hadoop/etc/hadoop/temp.xml
sudo grep -v "</configuration>" /usr/local/hadoop/etc/hadoop/temp.xml > /usr/local/hadoop/etc/hadoop/yarn-site.xml
sudo /bin/cat <<EOM >> /usr/local/hadoop/etc/hadoop/yarn-site.xml
<configuration>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
                <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
        <property>
                <name>yarn.resourcemanager.resource-tracker.address</name>
                <value>$master:8025</value>
        </property>
        <property>
                <name>yarn.resourcemanager.scheduler.address</name>
                <value>$master:8035</value>
        </property>
        <property>
                <name>yarn.resourcemanager.address</name>
                <value>$master:8050</value>
        </property>
</configuration>
EOM
cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
sudo grep -v "<configuration>" /usr/local/hadoop/etc/hadoop/mapred-site.xml > /usr/local/hadoop/etc/hadoop/temp.xml
sudo grep -v "</configuration>" /usr/local/hadoop/etc/hadoop/temp.xml > /usr/local/hadoop/etc/hadoop/mapred-site.xml
sudo /bin/cat <<EOM >> /usr/local/hadoop/etc/hadoop/mapred-site.xml
<configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
        <property>
                <name>mapreduce.job.tracker</name>
                <value>$master:5431</value>
        </property>
</configuration>
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
    scp yarn-site.xml hdfs-site.xml mapred-site.xml core-site.xml masters slaves root@$name:/usr/local/hadoop/etc/hadoop
    scp -o "StrictHostKeyChecking no" /opt/cluster-info.txt root@$name:/opt/cluster-info.txt
    scp /etc/hosts root@$name:/etc/hosts
	ssh -o "StrictHostKeyChecking no" root@$name << EOF
	rm -rf /usr/local/hadoop_tmp/hdfs/datanode/current
EOF
fi
done <"$file"
cd /usr/local/hadoop_tmp
hdfs namenode -format
