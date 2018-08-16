# Connect from docker to remote SQL Server on Linux

To connect from within a docker container to an external SQL Server

```
{
  "ConnectionStrings": {
    "SAC": "Server=192.168.x.x,1433;Initial Catalog=DatabaseName;User Id=sa;Password=1234"
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

Run container with webapp

```
docker run --rm -d -p 8080:8080 --name digiturno.web company/mywebapp
```
