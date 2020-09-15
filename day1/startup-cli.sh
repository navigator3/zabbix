sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo setenforce 0
echo "${name}_${surname}"
echo "${ip_zabbix_serv_int} \
privet" > /tmp/scripts/test_ip

#sudo mkdir -p /opt/zabbix-agent
#sudo yum install -y wget

#sudo wget https://www.zabbix.com/downloads/5.0.0/zabbix_agent-5.0.0-linux-3.0-amd64-static.tar.gz -O /opt/zabbix-agent/zabbix-agetn.tar.gz
#tar -xvf /opt/zabbix-agent/zabbix-agetn.tar.gz

#sudo sed -i '11c PidFile=/tmp/zabbix_agentd.pid' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '21c LogType=file' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '53c DebugLevel=3' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '115c Server=${ip_zabbix_serv_int}' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '123c ListenPort=10050' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '131c ListenIP=0.0.0.0' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '140c StartAgents=3' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '156c ServerActive=${ip_zabbix_serv_int}:10051' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '167c Hostname=zabbix_my' /opt/zabbix-agent/conf/zabbix_agentd.conf
#sudo sed -i '175c HostnameItem=system.hostname' /opt/zabbix-agent/conf/zabbix_agentd.conf

sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all

sudo yum install -y zabbix-agent

name=$(hostname)
sudo sed -i '57c DebugLevel=3' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '117c Server=${ip_zabbix_serv_int}' /etc/zabbix/zabbix_agentd.conf
#sudo sed -i '125c ListenPort=10050' /etc/zabbix/zabbix_agentd.conf
#sudo sed -i '133c ListenIP=0.0.0.0' /etc/zabbix/zabbix_agentd.conf
#sudo sed -i '142c StartAgents=3' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '158c ServerActive=${ip_zabbix_serv_int}' /etc/zabbix/zabbix_agentd.conf
sudo sed -i "169c Hostname=zabbix $name" /etc/zabbix/zabbix_agentd.conf
sudo sed -i '199c HostMetadataItem=system.uname' /etc/zabbix/zabbix_agentd.conf


#####for automative add to server need /etc/zabbix/zabbix_agentd.conf
# plus action rules on server
#PidFile=/var/run/zabbix/zabbix_agentd.pid
#LogFile=/var/log/zabbix/zabbix_agentd.log
#LogFileSize=0
#Server=10.1.2.10
#ServerActive=10.1.2.10
#Hostname=Zabbix auto agent
#HostMetadataItem=system.uname
#Include=/etc/zabbix/zabbix_agentd.d/*.conf


sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
