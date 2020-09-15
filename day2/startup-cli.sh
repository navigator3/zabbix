sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo setenforce 0
echo "${name}_${surname}"
echo "${ip_zabbix_serv_int} \
privet" > /tmp/scripts/test_ip


#>>>>>> install Tomcat<<<<<<

sudo yum install -y java-1.8.0-openjdk-devel
sudo mkdir -p /opt/tomcat
cd /opt/tomcat/
sudo yum install -y wget
sudo wget https://mirror.datacenter.by/pub/apache.org/tomcat/tomcat-8/v8.5.57/bin/apache-tomcat-8.5.57.tar.gz
sudo tar -zxvf apache-tomcat-8.5.57.tar.gz
sudo chmod 777 /opt/tomcat/apache-tomcat-8.5.57/logs
sudo chmod 777 /opt/tomcat/apache-tomcat-8.5.57/logs/catalina.out
sudo /opt/tomcat/apache-tomcat-8.5.57/bin/startup.sh
sudo touch /opt/tomcat/apache-tomcat-8.5.57/webapps/my.war



#>>>>>> install zabbix-agent <<<<<<

sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all

sudo yum install -y zabbix-agent


#>>>>>> set agent settings to autoActive mod <<<<<<

name=$(hostname)
sudo sed -i '57c DebugLevel=3' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '117c Server=${ip_zabbix_serv_int}' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '158c ServerActive=${ip_zabbix_serv_int}' /etc/zabbix/zabbix_agentd.conf
sudo sed -i "169c Hostname=zabbix $name" /etc/zabbix/zabbix_agentd.conf
sudo sed -i '199c HostMetadataItem=system.uname' /etc/zabbix/zabbix_agentd.conf


sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
