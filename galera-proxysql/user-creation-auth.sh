#command to create a database and import data

CREATE DATABASE world;

CREATE USER 'backend'@'%' IDENTIFIED BY 'backend123!';
GRANT ALL PRIVILEGES ON world.* TO 'backend'@'%';
FLUSH PRIVILEGES;
EXIT


#add the same user in proxysql

INSERT INTO mysql_users (username, password, default_hostgroup, transaction_persistent) VALUES ('app', 'app', 0, 0);
UPDATE mysql_users SET default_schema = 'world' WHERE username = 'app';
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;


SELECT username, password, default_hostgroup , default_schema FROM mysql_users WHERE username='app';



--backend user creation on galera cluster db

CREATE USER 'app'@'%' IDENTIFIED BY 'app';

GRANT ALL PRIVILEGES ON *.* TO 'app'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;





# select * from mysql_users


#user with hased password.


CREATE USER 'app2'@'%' IDENTIFIED BY 'app2';
GRANT ALL PRIVILEGES ON *.* TO 'app2'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;


# INSERT INTO mysql_users (
#   username,
#   password,
#   default_hostgroup,
#   active,
#   frontend,
#   backend
# ) VALUES (
#   'app2',
#   CACHING_SHA2_PASSWORD('app2'),
#   0,
#   1,
#   1,
#   1
# );


INSERT INTO mysql_users (
  username,
  password,
  default_hostgroup,
  active,
  frontend,
  backend
) VALUES (
  'app2',
  MYSQL_NATIVE_PASSWORD('app2'),
  0,
  1,
  1,
  1
);


LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;


mysql -u app2 -papp2  -h 172.16.181.132

#download sample world.sql db and imprort  
wget https://downloads.mysql.com/docs/world-db.tar.gz
gunzip world-db.tar.gz
 tar -xvf world-db.tar
mysql -u root -p world < world.sql

 mysql -u app2 -p -h 172.16.181.132  world < world-db/world.sql




 #testing THE DB queries

 mysql --user=app --password=app --host=172.16.181.132 --port=3306 -e "select * from world.city;"
 mysql --user=app --password=app --host=172.16.181.132 --port=3306 -e "select @@hostname;;"