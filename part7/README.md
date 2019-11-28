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

# Benchmark

Install `sysbench` inside the container:
```sh
docker-compose exec otusdb /bin/bash
apt-get update && apt-get install -y sysbench
```

Prepare test table:
```sh
sysbench --mysql-host=localhost --mysql-user=root --mysql-password=12345 \
         --db-driver=mysql --mysql-db=otusdb \
         --test=oltp --oltp-table-size=10000  \
         --mysql-table-engine=innodb \
         prepare
```

Run test:
```sh
sysbench --mysql-host=localhost --mysql-user=root --mysql-password=12345 \
         --db-driver=mysql --mysql-db=otusdb \
         --test=oltp --oltp-table-size=10000 \
         --num-threads=2 --max-requests=500 \
         run
```

Clean up test table:
```sh
sysbench --mysql-host=localhost --mysql-user=root --mysql-password=12345 \
         --db-driver=mysql --mysql-db=otusdb \
         --test=oltp\
         cleanup
```
