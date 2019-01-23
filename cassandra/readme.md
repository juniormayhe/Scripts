# Cassandra

## GUI
Use Datastax Devcenter 1.6.0 to connect to cassandra
https://academy.datastax.com/downloads?destination=downloads&dxt=DX

## To import CQL script (if you have python and csqlsh installed)
```
cqlsh localhost 9042 -f c:\temp\cassandra-single-file.cql
```

## Create keyspace if does not existin in Cassandra
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
	PRIMARY KEY (id, client_id)
);
```
