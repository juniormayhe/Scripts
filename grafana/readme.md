# Grafana

## Installing and running graphite and grafana docker containers
```
docker run -d --name graphite --restart=always -p 80:80 -p 2003-2004:2003-2004 -p 2023-2024:2023-2024 -p 8125:8125/udp -p 8126:8126 graphiteapp/graphite-statsd
docker run -d --name=grafana -p 3000:3000 grafana/grafana
```

- Test graphite login

Go to http://localhost:81/ with credentials root/root

To add user or change users permissions go to http://localhost:81/admin/auth/user/

- Test grafana login

Login to local grafana with user pass admin/admin

http://localhost:3000/login

### Setup grafana Settings

- Go to Configuration icon > Data sources > Add new datasource
- In HTTP > Url enter your `IP:port` where graphite is running. Do not enter localhost or 127.0.0.1 since grafana container has no graphite process running within the same container.
- Click on Save & Test button

## Installing Graphite on Linux host

Graphite stores time-series data to track the performance of their websites, applications, business services, and networked servers. It can visualize metrics in a simple way and not as sophisticated as grafana does.

It has two modules, graphite-web (frontend) and graphite-carbon (backend to collect metrics)

### Update packages
```
sudo apt-get update
sudo apt-get-upgrade
sudo reboot
```

### Install graphite
```
sudo apt-get install graphite-web graphite-carbon
sudo apt-get install apache2
```

### Install dependencies 

Graphite web is a WSGI script (specification for mapping webserver and graphite-web python web app)
```
sudo apt-get install libapache2-mod-wsgi
```

### Configure Graphite settings
```
vi /etc/graphite/local_settings.py
```
Uncomment secret
```
SECRET_KEY = 'my secret key'
```

Uncomment timezone
```
TIME_ZONE = 'America/Los_Angeles'
```

Move to Database configuration section change the ENGINE section to use the desired database format
```
DATABASES = {
	'default': {
		'NAME': '/var/lib/graphite/graphite.db',// for other formats like MySQL, create an empty database, remove var path and put database name here 
		'ENGINE': 'django.db.backends.sqlite3',...
		'PORT': ''// If you didn't change default port just leave this as is
	}
}
```

### Create graphite database objects

> this command does not work in some versions of graphite. We have to check if migrate.py syncdb mentioned in settings does what is needed of if this command is not needed anymore

```
cd /usr/bin
sudo django-admin migrate --settings=graphite.settings --run-syncdb
```

### Enable carbon cache
```
cd /usr/bin
sudo vi /etc/default/graphite-carbon
```
set to true
```
CARBON_CACHE_ENABLED=true
```

Start carbon cache service
```
sudo systemctl start carbon-cache
sudo systemctl enable carbon-cache
```

### Setup graphite web site

Remove default apache web site and add a graphite as default web site
```
cd /usr/bin
sudo a2dissite 000-default
sudo cp /usr/share/graphite-web/apach2-graphite.conf /etc/apache2/sites-available
cd /usr/share/graphite-web
sudo a2ensite apache2-graphite
sudo systemctl stop apache2
sudo systemctl start apache2
```
Error logs for apache can be found in /var/log/apache2/graphite-web_error.log
Give permissions to write in folder logs
```
cd /var/log/graphite
sudo chmod 755 info.log
sudo chmod 755 exception.log
```

It is recommended to set the _graphite user to be owner of these files
```
sudo chown _graphite info.log
sudo chown _graphite exception.log
sudo systemctl stop apache2
sudo systemctl start apache2
```
Error with databases will show up in exception.log
Give write permissions to database
```
sudo chown _graphite:_graphite /var/lib/graphite/graphite.db
sudo systemctl stop apache2
sudo systemctl start apache2
```

### Install StatsD

Download and install nodejs
```
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y
```

Download, configure and start statsd. Statsd listens to 8125 for udp packages and uses port 2003 to send data to Graphite carbon
```
sudo apt-get install git
cd /opt
sudo git clone git://github.com/etsy/statsd.git
sudo vi /opt/statsd/localConfig.js
{
graphitePort: 2003,
graphiteHost: '127.0.0.1',
port:8125
}
sudo systemctl restart carbon-cache
cd /opt/statsd
sudo node ./stats.js ./localConfig.js
```

restart container and login with admin/admin

### Configure sampling frequency and retention policy in graphite aggregator

Edit aggregator settings
```
sudo vi /etc/carbon/storage-schemas.conf
```
```
# we name our policy as [carbon]
# for a bucket begins with carbon and anything else after, capture every 60 seconds and keep it for 90days
# when we don't add s, m, h or d, sampling frequency assumes seconds

[carbon]
pattern = ^carbon\.
retentions = 60:90d

# add your sections here
```
after changing settings, restart apache
```
sudo systemctl stop apache2
sudo systemctl start apache2
```

## Send data to statsd
- https://github.com/aussiearef/StatsDBash/blob/master/StatD.sh
- https://github.com/aussiearef/StatsDPS/blob/master/StatsD.ps1
- https://github.com/aussiearef/StatsD-Client/blob/master/StatsDClient/StatsD.cs

## Add datasource in grafana

- Run grafana and graphite containers
- Go to http://localhost:3000/login
- Go to configuration icon > Data sources > Add data source, choose "Graphite"
- In Settings, 
  - type the datasource name in Name field
  - type the graphite ip address http://localhost:81 in URL field
  - choose Server (default) in Access field to allow grafana server fetch datasource. Browser option is used to allow browser do direct calls to graphite datasource.
  - click on Save and test
- 

