Since `/usr/lib/oracle/12.2/client64/network/admin/TNSNAMES.ora` cannot be found within microsoft/dotnet docker image, even with Oracle client installed, we have to add full connection at `Data Source` attribute:

## netcore appsettings.json within docker

```
{
  "ConnectionStrings": {
    "SAC": "User Id=username;Password=pass;Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.x.x)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=your-service-name)))"
  },
  "Logging": {
    "IncludeScopes": false,
    "Debug": {
      "LogLevel": {
        "Default": "Warning"
      }
    },
    "Console": {
      "LogLevel": {
        "Default": "Warning"
      }
    }
  }
}
```

## converting rpm files

RPM files for Oracle instant client 12:

https://github.com/leonnleite/instant-client-oracle

all needed rpms must be converted to ubuntu format with `alien`

## Installation tips
http://webikon.com/cases/installing-oracle-sql-plus-client-on-ubuntu
https://mikesmithers.wordpress.com/2011/04/03/oracle-instant-client-on-ubuntu-with-added-aliens/

