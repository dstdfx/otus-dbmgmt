# Start

```sh
docker-compose up otusdb
```

# Connect

```sh
docker-compose exec otusdb mysql -u root -p12345 otusdb
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

# Restore DB schema

Dump file: [otus_db-4560-3521f1.dmp](https://github.com/dstdfx/otus-dbmgmt/blob/master/part17/otus_db-4560-3521f1.dmp)

Get container's tty:
```bash
docker-compose exec otusdb /bin/bash
```
Apply DB schema from dump file:
```bash
mysql -u root -p12345 otusdb < /var/lib/mysql-files/otus_db-4560-3521f1.dmp
```

Or login to database:
```bash
docker-compose exec otusdb mysql -u root -p12345 otusdb
```

And apply schema using `source` command:
```bash
mysql> source /var/lib/mysql-files/otus_db-4560-3521f1.dmp
```

Check results:
```sql
mysql> show tables;
+------------------+
| Tables_in_otusdb |
+------------------+
| Python_Employee  |
| articles         |
| bin_test         |
| myset            |
| otus_test        |
| otus_test_myisam |
| python_employee  |
| sbtest1          |
| shirts           |
| t1               |
| t_uuid           |
| time_test        |
| time_test2       |
| time_test3       |
+------------------+
14 rows in set (0.00 sec)
```

# Restore data from backup file

Prepare system and install xtrabackup:
```bash
apt update && apt install -y wget lsb-release
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
percona-release enable-only tools release
apt-get update
apt-get install -y percona-xtrabackup-80
```

Decrypt backup:
```bash
openssl des3 -salt -k "password" -d -in /var/lib/mysql-files/backup.xbstream.gz-4560-0d8b3a.des3 -md md5 -out backup.xbstream.gz
gzip -d backup.xbstream.gz
```

Extract backup from stream:
```bash
mkdir backup && cd backup
xbstream -x < backup.xbstream
```

Prepare backup:
```bash
xtrabackup --prepare --apply-log-only --target-dir=backup
```
