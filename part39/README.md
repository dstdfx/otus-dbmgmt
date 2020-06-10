## MongoDB shared cluster with replication

### Environment

```bash
docker --version
Docker version 19.03.8, build afacb8b
```

```bash
docker-compose --version
docker-compose version 1.25.5, build 8a1c60f6
```

#### MongoDB setup

- 1 Config Server (3 members in replica set): `config01`,`config02`,`config03`
- 3 shards of MongoDB (3 members per shard, 1 primary, 2 secondary):
  - `shard01a`, `shard01b`, `shard01c`
  - `shard02a`, `shard02b`, `shard02c`
  - `shard03a`, `shard03b`, `shard03c`
- 1 Router (mongos): `router`

#### Run

Run `docker-compose` setup in demonized regime:
```bash
docker-compose up -d
```

Make sure all services are up and running:
```bash
docker-compose ps
      Name                     Command               State            Ports
-------------------------------------------------------------------------------------
part39_config01_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_config02_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_config03_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_router_1     docker-entrypoint.sh mongo ...   Up      0.0.0.0:27017->27017/tcp
part39_shard01a_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard01b_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard01c_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard02a_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard02b_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard02c_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard03a_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard03b_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
part39_shard03c_1   docker-entrypoint.sh mongo ...   Up      27017/tcp
```

Make init script excitable and run it, it will initialize the config server, shards and router:
```bash
chmod a+x init.sh
./init.sh
```

Output: [init-output.txt](outputs/init.txt)

#### Add sharding, choose sharding key and generate some test data

```bash
docker-compose exec router mongo
```

```bash
// Enable shardfing for `otusdb`
mongos> sh.enableSharding("otusdb")
{
	"ok" : 1,
	"operationTime" : Timestamp(1591819216, 5),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1591819216, 5),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}

// Setup sharding key for `otusdb.suppliers` collection
mongos> db.adminCommand( { shardCollection: "otusdb.suppliers", key: { supplierId: "hashed" } } )
{
	"collectionsharded" : "otusdb.suppliers",
	"collectionUUID" : UUID("695c0729-5582-4e44-992f-5e66026ffd3d"),
	"ok" : 1,
	"operationTime" : Timestamp(1591819419, 44),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1591819419, 44),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}

// Add test data
mongos> for (var i=0; i<100000; i++) { db.suppliers.insert({supname: "example", amount: Math.random()}) }
```

#### Verify

```bash
docker-compose exec router mongo
```

Verify shared cluster status: 
```bash
mongos> sh.status()
--- Sharding Status ---
  sharding version: {
  	"_id" : 1,
  	"minCompatibleVersion" : 5,
  	"currentVersion" : 6,
  	"clusterId" : ObjectId("5ee134075fb2d10f0ca8e8dc")
  }
  shards:
        {  "_id" : "shard01",  "host" : "shard01/shard01a:27018,shard01b:27018,shard01c:27018",  "state" : 1 }
        {  "_id" : "shard02",  "host" : "shard02/shard02a:27019,shard02b:27019,shard02c:27019",  "state" : 1 }
        {  "_id" : "shard03",  "host" : "shard03/shard03a:27020,shard03b:27020,shard03c:27020",  "state" : 1 }
  active mongoses:
        "4.0.18" : 1
  autosplit:
        Currently enabled: yes
  balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours:
                No recent migrations
  databases:
        {  "_id" : "config",  "primary" : "config",  "partitioned" : true }
                config.system.sessions
                        shard key: { "_id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                shard01	1
                        { "_id" : { "$minKey" : 1 } } -->> { "_id" : { "$maxKey" : 1 } } on : shard01 Timestamp(1, 0)
        {  "_id" : "otusdb",  "primary" : "shard02",  "partitioned" : true,  "version" : {  "uuid" : UUID("c6ae8b4a-bd9f-49c6-9f0a-76817c94b4c2"),  "lastMod" : 1 } }
                otusdb.suppliers
                        shard key: { "supplierId" : "hashed" }
                        unique: false
                        balancing: true
                        chunks:
                                shard01	2
                                shard02	2
                                shard03	2
                        { "supplierId" : { "$minKey" : 1 } } -->> { "supplierId" : NumberLong("-6148914691236517204") } on : shard01 Timestamp(1, 0)
                        { "supplierId" : NumberLong("-6148914691236517204") } -->> { "supplierId" : NumberLong("-3074457345618258602") } on : shard01 Timestamp(1, 1)
                        { "supplierId" : NumberLong("-3074457345618258602") } -->> { "supplierId" : NumberLong(0) } on : shard02 Timestamp(1, 2)
                        { "supplierId" : NumberLong(0) } -->> { "supplierId" : NumberLong("3074457345618258602") } on : shard02 Timestamp(1, 3)
                        { "supplierId" : NumberLong("3074457345618258602") } -->> { "supplierId" : NumberLong("6148914691236517204") } on : shard03 Timestamp(1, 4)
                        { "supplierId" : NumberLong("6148914691236517204") } -->> { "supplierId" : { "$maxKey" : 1 } } on : shard03 Timestamp(1, 5)
```

Verify replicaset statuses for each shard:
```bash
docker-compose exec shard01a bash -c "echo 'rs.status()' | mongo --port 27018"
docker-compose exec shard02a bash -c "echo 'rs.status()' | mongo --port 27019"
docker-compose exec shard03a bash -c "echo 'rs.status()' | mongo --port 27020"
```

Outputs:
- [rs-status-shard01a.txt](outputs/rs-status-shard01a.txt)
- [rs-status-shard02a.txt](outputs/rs-status-shard02a.txt)
- [rs-status-shard03a.txt](outputs/rs-status-shard03a.txt)

#### Kill primary node in `shard01`

Status sample before: 
```bash
	"members" : [
		{
			"_id" : 0,
			"name" : "shard01a:27018",
			"health" : 1,
			"state" : 1,
			"stateStr" : "PRIMARY",
			"uptime" : 4898,
			"optime" : {
				"ts" : Timestamp(1591821795, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2020-06-10T20:43:15Z"),
			"syncingTo" : "",
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "",
			"electionTime" : Timestamp(1591817224, 1),
			"electionDate" : ISODate("2020-06-10T19:27:04Z"),
			"configVersion" : 1,
			"self" : true,
			"lastHeartbeatMessage" : ""
		},
		{
			"_id" : 1,
			"name" : "shard01b:27018",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 4584,
			"optime" : {
				"ts" : Timestamp(1591821795, 1),
				"t" : NumberLong(1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1591821795, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2020-06-10T20:43:15Z"),
			"optimeDurableDate" : ISODate("2020-06-10T20:43:15Z"),
			"lastHeartbeat" : ISODate("2020-06-10T20:43:19.129Z"),
			"lastHeartbeatRecv" : ISODate("2020-06-10T20:43:18.645Z"),
			"pingMs" : NumberLong(0),
			"lastHeartbeatMessage" : "",
			"syncingTo" : "shard01a:27018",
			"syncSourceHost" : "shard01a:27018",
			"syncSourceId" : 0,
			"infoMessage" : "",
			"configVersion" : 1
		},
		{
			"_id" : 2,
			"name" : "shard01c:27018",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 4584,
			"optime" : {
				"ts" : Timestamp(1591821795, 1),
				"t" : NumberLong(1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1591821795, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2020-06-10T20:43:15Z"),
			"optimeDurableDate" : ISODate("2020-06-10T20:43:15Z"),
			"lastHeartbeat" : ISODate("2020-06-10T20:43:19.132Z"),
			"lastHeartbeatRecv" : ISODate("2020-06-10T20:43:18.645Z"),
			"pingMs" : NumberLong(0),
			"lastHeartbeatMessage" : "",
			"syncingTo" : "shard01a:27018",
			"syncSourceHost" : "shard01a:27018",
			"syncSourceId" : 0,
			"infoMessage" : "",
			"configVersion" : 1
		}
```

Stop `shard01a` node: 
```bash
docker stop part39_shard01a_1
```

Check if new `primary` has been selected: 
```bash
docker-compose exec shard01b bash -c "echo 'db.isMaster()' | mongo --port 27018"
MongoDB shell version v4.0.18
connecting to: mongodb://127.0.0.1:27018/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("b5c68123-51ba-4f76-88b1-c6630cd3bfc4") }
MongoDB server version: 4.0.18
{
	"hosts" : [
		"shard01a:27018",
		"shard01b:27018",
		"shard01c:27018"
	],
	"setName" : "shard01",
	"setVersion" : 1,
	"ismaster" : true,
	"secondary" : false,
	"primary" : "shard01b:27018",
	"me" : "shard01b:27018",
```

Run to bring `shard01a` node to life:
```bash
docker start part39_shard01a_1
``` 

### Authentication

Create new user with role:
```bash
mongos> db.getSiblingDB("otusdb").runCommand( {
...        createUser: "newAdmin",
...        pwd: "123",
...        customData: { employeeId: 12345 },
...        roles: [
...                 { role: "clusterAdmin", db: "admin" },
...                 { role: "readAnyDatabase", db: "admin" },
...                 "readWrite"
...               ],
...        writeConcern: { w: "majority" , wtimeout: 5000 }
... } )
{
	"ok" : 1,
	"operationTime" : Timestamp(1591823336, 4),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1591823336, 4),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}
```

### Clean up 

```bash
docker-compose down -v --remove-orphans
```
