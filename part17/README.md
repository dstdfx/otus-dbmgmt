# Start

```sh
docker-compose up otusdb
```

# Connect

```sh
docker-compose exec otusdb mysql -u root -p12345 otus
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
root@2713756a6743:/# mysql -u root -p12345 otus < /var/lib/mysql-files/otus_db-4560-3521f1.dmp
```

Or login to database:
```bash
docker-compose exec otusdb mysql -u root -p12345 otus
```

And apply schema using `source` command:
```bash
mysql> source /var/lib/mysql-files/otus_db-4560-3521f1.dmp
```

Check results:
```sql
mysql> show tables;
+------------------+
| Tables_in_otus   |
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

# Restore individual table from encrypted backup file

Install required packages:
```bash
root@2713756a6743:/# apt update && apt install -y wget lsb-release
```

Set up percona repos:
```bash
root@2713756a6743:/# wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
root@2713756a6743:/# dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
root@2713756a6743:/# percona-release enable-only tools release
```

Install `xtrabackup`:
```bash
root@2713756a6743:/# apt-get update && apt-get install -y percona-xtrabackup-80
```

Decrypt backup and extract backup from stream:
```bash
root@2713756a6743:/# mkdir otus_backup && cd otus_backup
root@2713756a6743:/otus_backup# openssl des3 -salt -k "password" -d -in /var/lib/mysql-files/backup.xbstream.gz-4560-0d8b3a.des3 -md md5 -out backup.xbstream.gz
root@2713756a6743:/otus_backup# gzip -d backup.xbstream.gz
root@2713756a6743:/otus_backup# xbstream -x < backup.xbstream
```

Prepare backup (inside `otus_backup` dir):
```bash
root@2713756a6743:/otus_backup# xtrabackup --prepare --export --target-dir=.
```

Discard `articles` table tablespace:
```bash
root@2713756a6743:/otus_backup# mysql -u root -p12345 otus
```
```sql
mysql> ALTER TABLE articles DISCARD TABLESPACE;
Query OK, 0 rows affected (0.08 sec)
```

Copy `articles` table's related files to `/var/lib/mysql/otus`:
```bash
root@2713756a6743:/otus_backup# cp otus/articles.* /var/lib/mysql/otus/
```

Change owner of copied files to `mysql`:
```bash
root@2713756a6743:/otus_backup# chown mysql:mysql /var/lib/mysql/otus/articles.*
```

Import copied tablespace:
```bash
ALTER TABLE articles IMPORT TABLESPACE;
```

Check table data:
```sql
mysql> select * from articles;
+----+-----------------------+------------------------------------------+
| id | title                 | body                                     |
+----+-----------------------+------------------------------------------+
|  1 | MySQL Tutorial        | DBMS stands for DataBase ...             |
|  2 | How To Use MySQL Well | After you went through a ...             |
|  3 | Optimizing MySQL      | In this tutorial we will show ...        |
|  4 | 1001 MySQL Tricks     | 1. Never run mysqld as root. 2. ...      |
|  5 | MySQL vs. YourSQL     | In the following database comparison ... |
|  6 | MySQL Security        | When configured properly, MySQL ...      |
|  7 | Oracle configuration  | Beginning guide                          |
|  8 | RDBMS course          | Trash and hell                           |
|  9 | RDBMS course2         | Trash and hell2                          |
| 10 | RDBMS course3         | Trash and hell3                          |
| 11 | RDBMS course10        | Trash and hell10                         |
+----+-----------------------+------------------------------------------+
11 rows in set (0.00 sec)
```

Helpful links:
- https://www.percona.com/doc/percona-xtrabackup/LATEST/xtrabackup_bin/restoring_individual_tables.html
