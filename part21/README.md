# Start

```sh
docker-compose up otusdb
```

# Connect

With interactive password input (default password is `otusdb`):
```sh
docker-compose exec postgres psql -h postgres -U otusdb
```
via URL:
```sh
docker-compose exec postgres psql "postgresql://otusdb:otusdb@postgres/otusdb"
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

# Verify

```bash
$ docker-compose exec postgres psql "postgresql://otusdb:otusdb@postgres/otusdb"
psql (10.11 (Debian 10.11-1.pgdg90+1))
Type "help" for help.

otusdb=#
otusdb=# select version();
                                                              version
------------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 10.11 (Debian 10.11-1.pgdg90+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 6.3.0-18+deb9u1) 6.3.0 20170516, 64-bit
(1 row)
```
