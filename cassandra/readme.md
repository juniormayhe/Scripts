# Cassandra

## GUI
Use Datastax Devcenter 1.6.0 to connect to cassandra
https://academy.datastax.com/downloads?destination=downloads&dxt=DX

## To import CQL script (if you have python and csqlsh installed)
```
cqlsh localhost 9042 -f c:\temp\cassandra-single-file.cql
```

## Create user if does not existin in Cassandra
```
CREATE ROLE IF NOT EXISTS keyspacename WITH PASSWORD = '1234' AND LOGIN = true AND SUPERUSER = false;
```

## Grant user rights on cassandra keyspace
```
GRANT SELECT ON ALL KEYSPACES TO keyspacename;
GRANT MODIFY ON ALL KEYSPACES TO keyspacename;
```

## Create user defined type
```
use keyspacename;

CREATE TYPE IF NOT EXISTS location (
   geo_location tuple<text, text>,
   zip_code text,
   city_id int,
   state_id int,
   country_id text
);

CREATE TABLE IF NOT EXISTS customer (
	id uuid,
	client_id int,
	name text,
	location FROZEN<location>,
	enabled boolean,
	PRIMARY KEY (id, client_id)
);
```

## Create view
```
use keyspacename;

CREATE MATERIALIZED VIEW IF NOT EXISTS vw_clients AS
SELECT * FROM client
WHERE id IS NOT NULL AND client_id IS NOT NULL
PRIMARY KEY ((id, client_id), name);
```

## Insert record
```
use keyspacename;

INSERT INTO customer JSON
'{
    "id": "a06de7a1-4845-4eef-860a-0106dc7e1ba1",
    "client_id":"27000",
    "entity_id":"c3317c6e-d594-4dab-9948-0153a8091b68",
    "type": "Brand",
    "location": {
       "geo_location": ["",""],
       "country_id":"BR"
    }
}' IF NOT EXISTS;

```

## Update record and delete
```
use keyspacename;

UPDATE customer SET enabled = true WHERE id = a06de7a1-4845-4eef-860a-0106dc7e1ba2 and client_id=1 IF EXISTS;

delete from customer where id = a06de7a1-4845-4eef-860a-0106dc7e1ba2;
```
