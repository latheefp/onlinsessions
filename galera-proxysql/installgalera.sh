ref: https://github.com/sysown/proxysql/issues/3446

echo 172.16.181.135 db2 >>/etc/hosts
echo 172.16.181.138 db1 >>/etc/hosts
echo 172.16.181.139 db3 >>/etc/hosts



sudo apt update
sudo apt install mariadb-server galera-4 rsync vim iputils-ping -y

systemctl status mariadb.service

#update my.cnf in all three nodes. 
sudo galera_new_cluster

#system status on first nodes. 

mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size';"

sudo systemctl start mariadb

mysql -u root -p -e "SHOW STATUS LIKE 'wsrep%';"



#create a monitoring user for backend DB, 

CREATE USER 'proxy_monitor'@'%' IDENTIFIED BY 'abc1234';
GRANT USAGE ON *.* TO 'proxy_monitor'@'%';
FLUSH PRIVILEGES;



#installing proxysql
sudo apt update
sudo apt install -y wget gnupg2 lsb-release


apt-get install -y --no-install-recommends lsb-release wget apt-transport-https ca-certificates gnupg
wget -O - 'https://repo.proxysql.com/ProxySQL/proxysql-3.0.x/repo_pub_key' | apt-key add - 
echo deb https://repo.proxysql.com/ProxySQL/proxysql-3.0.x/$(lsb_release -sc)/ ./ | tee /etc/apt/sources.list.d/proxysql.list
apt update; apt install proxysql vim mariadb-client -y


systemctl start proxysql


#update proxysql.conf


initial conf.

proxysql --initial -f --config-file=/etc/proxysql.cnf
chown proxysql:proxysql /var/lib/proxysql/proxysql.db
systemctl start proxysql
systemctl status proxysql
mysql -u admin -padmin -h 127.0.0.1 -P 6032

#make sure the 
SELECT * FROM mysql_servers;

#db status 
SELECT hostgroup_id, hostname, port, status FROM runtime_mysql_servers;

#Each check type has a dedicated logging table, each should be checked individually:
SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC LIMIT 3;

#udpate mysql port.

MySQL [(none)]> SELECT * FROM global_variables WHERE variable_name = 'mysql-interfaces';
+------------------+----------------+
| variable_name    | variable_value |
+------------------+----------------+
| mysql-interfaces | 0.0.0.0:6033   |
+------------------+----------------+
1 row in set (0.004 sec)


#update the mysql-interfaces to 3306
MySQL [(none)]> UPDATE global_variables SET variable_value = "0.0.0.0:3306" WHERE variable_name = 'mysql-interfaces';
Query OK, 1 row affected (0.003 sec)
SAVE MYSQL VARIABLES TO DISK;
MySQL [(none)]> SELECT * FROM global_variables WHERE variable_name = 'mysql-interfaces';
+------------------+----------------+
| variable_name    | variable_value |
+------------------+----------------+
| mysql-interfaces | 0.0.0.0:3306   |
+------------------+----------------+
1 row in set (0.008 sec)

#save the changes to disk and load the variables to runtime
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

sudo systemctl restart proxysql

#check the status of proxysql

SELECT * FROM global_variables  WHERE variable_name LIKE 'mysql-monitor%';


#also test the connectivity from proxysql to the backend DB

mysql -u proxy_monitor -h db1 -pabc1234