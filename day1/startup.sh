#!/bin/bash
sudo mkdir -p /tmp/startup
echo "${name}-${surname}-${ext_ip}-${int_ip}"
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo setenforce 0

sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all

sudo yum install -y zabbix-server-mysql zabbix-agent

sudo yum install -y centos-release-scl

sudo sed -i '11c enabled=1' /etc/yum.repos.d/zabbix.repo

yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl

cat > /etc/yum.repos.d/mariadb.repo << EOF
# MariaDB 10.5 CentOS repository list - created 2020-09-14 09:18 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

sudo yum install -y MariaDB-server MariaDB-client

sudo systemctl start mariadb
sudo /usr/bin/mysqladmin -u root 1qaz mariadbroot
dbuser='root'
dbpass='1qaz'

mysql -u$dbuser -p$dbpass -e 'create database if not exists zabbix character set utf8 collate utf8_bin';

uzabbix='zabbix' #pass to new user
Q1="create user zabbix@localhost identified by '$uzabbix';"
mysql -u$dbuser -p$dbpass -e "$Q1"
mysql -u$dbuser -p$dbpass -e 'grant all privileges on zabbix.* to zabbix@localhost';
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix zabbix

sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix

# "vnosim izmeneniya v /etc/zabbix/zabbix_server.conf"
sed -i "s/.*# DBHost=.*/DBHost=localhost/" /etc/zabbix/zabbix_server.conf
sed -i "s/.*# DBPassword=.*/DBPassword=$uzabbix/" /etc/zabbix/zabbix_server.conf

S1='Europe/Minsk'

sudo echo "php_value[date.timezone] = $S1" >> /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

rm /etc/zabbix/web/zabbix.conf.php
cat > /etc/zabbix/web/zabbix.conf.php << EOF
<?php
// Zabbix GUI configuration file.

\$DB['TYPE']                             = 'MYSQL';
\$DB['SERVER']                   = 'localhost';
\$DB['PORT']                             = '0';
\$DB['DATABASE']                 = 'zabbix';
\$DB['USER']                             = 'zabbix';
\$DB['PASSWORD']                 = 'zabbix';

// Schema name. Used for PostgreSQL.
\$DB['SCHEMA']                   = '';

// Used for TLS connection.
\$DB['ENCRYPTION']               = false;
\$DB['KEY_FILE']                 = '';
\$DB['CERT_FILE']                = '';
\$DB['CA_FILE']                  = '';
\$DB['VERIFY_HOST']              = false;
\$DB['CIPHER_LIST']              = '';

// Use IEEE754 compatible value range for 64-bit Numeric (float) history values.
// This option is enabled by default for new Zabbix installations.
// For upgraded installations, please read database upgrade notes before enabling this option.
\$DB['DOUBLE_IEEE754']   = true;
\$ZBX_SERVER                             = 'localhost';
\$ZBX_SERVER_PORT                = '10051';
\$ZBX_SERVER_NAME                = 'zabbix_my';

\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//\$HISTORY['url'] = [
//      'uint' => 'http://localhost:9200',
//      'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//\$HISTORY['types'] = ['uint', 'text'];

// Used for SAML authentication.
// Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
//\$SSO['SP_KEY']                        = 'conf/certs/sp.key';
//\$SSO['SP_CERT']                       = 'conf/certs/sp.crt';
//\$SSO['IDP_CERT']              = 'conf/certs/idp.crt';
//\$SSO['SETTINGS']              = [];
EOF

sudo systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm




#
