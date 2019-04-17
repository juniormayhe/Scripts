# Sonarqube installation

## Prepare a sonarqube on docker
Assuming you already have docker installed

Create a local folder called sonarqube with the following docker-compose.yml:
```
version: "2"

services:
  sonarqube:
    image: sonarqube
    ports:
      - "9000:9000"
    networks:
      - sonarnet
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
    volumes:
      - sonarqube_conf:/opt/sonarqube/conf
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_bundled-plugins:/opt/sonarqube/lib/bundled-plugins

  db:
    image: postgres
    ports:
      - "5432:5432"
    networks:
      - sonarnet
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
    volumes:
      - postgresql:/var/lib/postgresql
      # This needs explicit mapping due to https://github.com/docker-library/postgres/blob/4e48e3228a30763913ece952c611e5e9b95c8759/Dockerfile.template#L52
      - postgresql_data:/var/lib/postgresql/data

networks:
  sonarnet:
    driver: bridge

volumes:
  sonarqube_conf:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_bundled-plugins:
  postgresql:
  postgresql_data:
```

Go to sonarqube\ folder which contains docker-compose.yml then create and start sonarqube container:

```
docker-compose up 
```

Login as admin / admin at http://localhost:9000 and create a key for your project. Something as MySample

## Start analysis local dev environment
Assuming you have dotnet sdk installed

Install dotnet sonarscanner globally
```
dotnet tool install -g dotnet-sonarscanner --ignore-failed-sources
```

Start analysis with entering key that identifies your project (defined in http://localhost:9000)
```
dotnet sonarscanner begin /key:"MySample"
```

Build your solution
```
dotnet build RoutingService.sln -c Debug
```
If you have 401 error code in terminal / console while fetching package from proget, comment proget lines at `%appdata%\nuget\nuget.config`

```
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    
    <!--
    <add key="proget dev" value="https://proget-fqdn/nuget/Farfetch-NuGet-DEV/" />
    <add key="proget Live" value="https://proget-fqdn/nuget/Farfetch-NuGet-LIVE/" />
    -->

    <add key="Microsoft Visual Studio Offline Packages" value="C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\" />
  </packageSources>
  <packageRestore>
    <add key="enabled" value="True" />
    <add key="automatic" value="True" />
  </packageRestore>
  <bindingRedirects>
    <add key="skip" value="False" />
  </bindingRedirects>
  <packageManagement>
    <add key="format" value="0" />
    <add key="disabled" value="False" />
  </packageManagement>
</configuration>
```

Finish sonarscanner analysis
```
dotnet sonarscanner end
```

More on https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner+for+MSBuild
