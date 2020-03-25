# Start

```bash
$ vagrant up
$ ansible-playbook site.yml -i hosts
```

# Check

VM's:
```bash
$ vagrant status
Current machine states:

consul                    running (virtualbox)
app                       running (virtualbox)
pg0                       running (virtualbox)
pg1                       running (virtualbox)
pg2                       running (virtualbox)
haproxy                   running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Consul UI: `192.168.11.100:8500`

Patroni cluster status from host: 
```bash
$ patronictl list otus
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 |        | running |  3 |         0 |
|   otus  |  pg1   | 192.168.11.121 | Leader | running |  3 |           |
|   otus  |  pg2   | 192.168.11.122 |        | running |  3 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
```
Note that you need to have `PATRONI_CONSUL_HOST="192.168.11.100:8500"` in environment variables
otherwise you have to specify patroni config explicitly:
```bash
$ patronictl -c /etc/patroni/patroni.yml list
```

# Connect to vm's via SSH

```bash
vagrant ssh <vm-name>
```

# Stop

```bash
$ vagrant destroy
```

# Tasks 

#### Create database and check replication works

Connect to the leader (currently it's `pg1`, check `patronictl list` for that) and create test database:
```bash
$ psql -h 192.168.11.121 -U postgres
Password for user postgres:
psql (12.2, server 11.7 (Ubuntu 11.7-2.pgdg18.04+1))
Type "help" for help.
postgres=#
postgres=#
postgres=# select pg_is_in_recovery();
 pg_is_in_recovery
-------------------
 f
(1 row)
postgres=#
postgres=# create database testdb;
CREATE DATABASE
postgres=#
postgres=#
postgres=# \l
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+-----------------------
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 testdb    | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(4 rows)
```

Check replicas have `testdb`:
```bash
$ psql -h 192.168.11.122 -U postgres
Password for user postgres:
psql (12.2, server 11.7 (Ubuntu 11.7-2.pgdg18.04+1))
Type "help" for help.

postgres=# \l
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+-----------------------
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 testdb    | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(4 rows)
```

```bash
$ psql -h 192.168.11.120 -U postgres
Password for user postgres:
psql (12.2, server 11.7 (Ubuntu 11.7-2.pgdg18.04+1))
Type "help" for help.

postgres=# \l
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+-----------------------
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 testdb    | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(4 rows)
```

#### Switchover

```bash
$ patronictl switchover otus
Master [pg1]:
Candidate ['pg0', 'pg2'] []: pg0
When should the switchover take place (e.g. 2020-03-25T13:15 )  [now]:
Current cluster topology
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 |        | running |  3 |         0 |
|   otus  |  pg1   | 192.168.11.121 | Leader | running |  3 |           |
|   otus  |  pg2   | 192.168.11.122 |        | running |  3 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
Are you sure you want to switchover cluster otus, demoting current master pg1? [y/N]: y
2020-03-25 12:15:54.57497 Successfully switched over to "pg0"
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 | Leader | running |  3 |           |
|   otus  |  pg1   | 192.168.11.121 |        | stopped |    |   unknown |
|   otus  |  pg2   | 192.168.11.122 |        | running |  3 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
```

Check switchover is done: 
```bash
patronictl list otus
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 | Leader | running |  4 |           |
|   otus  |  pg1   | 192.168.11.121 |        | running |  4 |         0 |
|   otus  |  pg2   | 192.168.11.122 |        | running |  4 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
```

#### Failover 

Go to `pg0` and stop `patroni` process:
```bash
$ vagrant ssh pg0
$ systemctl stop patroni
```

Check cluster, leader has changed:
```bash
$ patronictl list otus
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 |        | stopped |    |   unknown |
|   otus  |  pg1   | 192.168.11.121 |        | running |    |   unknown |
|   otus  |  pg2   | 192.168.11.122 | Leader | running |  5 |           |
+---------+--------+----------------+--------+---------+----+-----------+
```

Failover using `patronictl`:
```bash
$ patronictl failover otus
Candidate ['pg0', 'pg1'] []: pg0
Current cluster topology
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 |        | running |  5 |         0 |
|   otus  |  pg1   | 192.168.11.121 |        | running |  5 |         0 |
|   otus  |  pg2   | 192.168.11.122 | Leader | running |  5 |           |
+---------+--------+----------------+--------+---------+----+-----------+
Are you sure you want to failover cluster otus, demoting current master pg2? [y/N]: y
2020-03-25 12:22:47.52456 Successfully failed over to "pg0"
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 | Leader | running |  5 |           |
|   otus  |  pg1   | 192.168.11.121 |        | running |  5 |         0 |
|   otus  |  pg2   | 192.168.11.122 |        | stopped |    |   unknown |
+---------+--------+----------------+--------+---------+----+-----------+
```

```bash
$ patronictl list otus
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 | Leader | running |  6 |           |
|   otus  |  pg1   | 192.168.11.121 |        | running |  6 |         0 |
|   otus  |  pg2   | 192.168.11.122 |        | running |  6 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
```

#### Patroni `edit-config`

```bash
$ patronictl edit-config otus
  ---
  +++
  @@ -7,11 +7,12 @@
         archive-push -B /var/backup --instance dbdc2 --wal-file-path=%p --wal-file-name=%f
         --remote-host=10.23.1.185
       archive_mode: 'on'
  -    max_connections: 100
  +    max_connections: 200
       max_parallel_workers: 8
       max_wal_senders: 5
       max_wal_size: 2GB
       min_wal_size: 1GB
     use_pg_rewind: true
   retry_timeout: 10
  +synchronous_mode: true
   ttl: 30
  
  Apply these changes? [y/N]: y
  Configuration changed
```

Check cluster status:
```bash
$ patronictl list otus
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |     Role     |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
|   otus  |  pg0   | 192.168.11.120 |    Leader    | running |  6 |           |        *        |
|   otus  |  pg1   | 192.168.11.121 |              | running |  6 |         0 |        *        |
|   otus  |  pg2   | 192.168.11.122 | Sync Standby | running |  6 |         0 |        *        |
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
```

Make switchover to restart nodes:
```bash
$ patronictl switchover otus
Master [pg0]:
Candidate ['pg1', 'pg2'] []: pg2
When should the switchover take place (e.g. 2020-03-25T13:41 )  [now]:
Current cluster topology
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |     Role     |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
|   otus  |  pg0   | 192.168.11.120 |    Leader    | running |  6 |           |        *        |
|   otus  |  pg1   | 192.168.11.121 |              | running |  6 |         0 |        *        |
|   otus  |  pg2   | 192.168.11.122 | Sync Standby | running |  6 |         0 |        *        |
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
Are you sure you want to switchover cluster otus, demoting current master pg0? [y/N]: y
2020-03-25 12:41:16.33972 Successfully switched over to "pg2"
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg0   | 192.168.11.120 |        | stopped |    |   unknown |        *        |
|   otus  |  pg1   | 192.168.11.121 |        | running |  6 |         0 |        *        |
|   otus  |  pg2   | 192.168.11.122 | Leader | running |  6 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
```

Make switchover once again, to get the last node restarted:
```bash
$ patronictl switchover otus
Master [pg2]:
Candidate ['pg0', 'pg1'] []: pg0
When should the switchover take place (e.g. 2020-03-25T13:42 )  [now]:
Current cluster topology
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |     Role     |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
|   otus  |  pg0   | 192.168.11.120 | Sync Standby | running |  7 |         0 |                 |
|   otus  |  pg1   | 192.168.11.121 |              | running |  7 |         0 |                 |
|   otus  |  pg2   | 192.168.11.122 |    Leader    | running |  7 |           |        *        |
+---------+--------+----------------+--------------+---------+----+-----------+-----------------+
Are you sure you want to switchover cluster otus, demoting current master pg2? [y/N]: y
2020-03-25 12:42:05.65280 Successfully switched over to "pg0"
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg0   | 192.168.11.120 | Leader | running |  7 |           |                 |
|   otus  |  pg1   | 192.168.11.121 |        | running |  7 |         0 |                 |
|   otus  |  pg2   | 192.168.11.122 |        | stopped |    |   unknown |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
```

Verify: 
```bash
$ patronictl list otus
+---------+--------+----------------+--------------+---------+----+-----------+
| Cluster | Member |      Host      |     Role     |  State  | TL | Lag in MB |
+---------+--------+----------------+--------------+---------+----+-----------+
|   otus  |  pg0   | 192.168.11.120 |    Leader    | running |  8 |           |
|   otus  |  pg1   | 192.168.11.121 |              | running |  8 |         0 |
|   otus  |  pg2   | 192.168.11.122 | Sync Standby | running |  8 |         0 |
+---------+--------+----------------+--------------+---------+----+-----------+
```

#### Haproxy

Configuration template is here: [haproxy.cfg.j2](https://github.com/dstdfx/otus-dbmgmt/blob/master/part30/roles/haproxy/templates/haproxy.cfg.j2)

Try to connect to postgresql through `haproxy`, it must route client connection 
to the leader (according to the configuration above):
```bash
$ psql -h 192.168.11.101 -p 5000 -U postgres
Password for user postgres:
psql (12.2, server 11.7 (Ubuntu 11.7-2.pgdg18.04+1))
Type "help" for help.

postgres=# select pg_is_in_recovery();
 pg_is_in_recovery
-------------------
 f
(1 row)
```
