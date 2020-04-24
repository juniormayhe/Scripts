# Cassandra

## GUI
Use Datastax Devcenter 1.6.0 to connect to cassandra
https://academy.datastax.com/downloads?destination=downloads&dxt=DX

## enable role creation and grant
Go to C:\Program Files\DataStax Community\apache-cassandra\conf\cassandra.yaml and change these lines:
```
#authenticator: AllowAllAuthenticator 
##enable creating role with password
authenticator: PasswordAuthenticator

#authorizer: AllowAllAuthorizer 
##enable grant to role
authorizer: org.apache.cassandra.auth.CassandraAuthorizer
```
then restart `DataStax Cassandra Community Server 3.0.9` in Windows Services or, `sudo service cassandra restart` in Linux

## To import CQL script (if you have python 2.7 and csqlsh installed)
```
cqlsh localhost 9042 -f c:\temp\cassandra-single-file.cql
```

## Datastax default user / password for cluster credentials
user: cassandra
password: cassandra
host: localhost:9042
compression: snappy

## Create database
```
CREATE KEYSPACE database_name WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : '1'};
```

## Create user if does not existin in Cassandra
```
use keyspacename;
CREATE ROLE IF NOT EXISTS rolename WITH PASSWORD = '1234' AND LOGIN = true AND SUPERUSER = false;
```

## Grant user rights on cassandra keyspace
```
GRANT SELECT ON ALL KEYSPACES TO rolename;
GRANT MODIFY ON ALL KEYSPACES TO rolename;
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
	reviews MAP<int, int>,
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
    },
    "reviews": {
        "1":"2",
        "2":"10",
        "3":"1",
        "4":"10",
        "5":"230"
    },
}' IF NOT EXISTS;

```

## Update record and delete
```
use keyspacename;

UPDATE customer SET enabled = true WHERE id = a06de7a1-4845-4eef-860a-0106dc7e1ba2 and client_id=1 IF EXISTS;

delete from customer where id = a06de7a1-4845-4eef-860a-0106dc7e1ba2;
```
