#!/bin/bash
clear
#instructions to install php7 and composer in Alpine
echo "****************************"
echo "Adding nginx in Alpine"
echo "****************************"
apk update
apk add wget nginx
echo "ATTENTION:"
echo "If you intend to install nginx and composer in Alpine, "
echo $"these instructions might help you:\n\n"
echo "In Alpine, do not touch /etc/nginx/nginx.conf"
echo "At /etc/nginx/conf.d/default.conf add within server {...} :"
echo "listen   [::]:80 default_server ipv6only=on;"
echo "        # Pass PHP scripts to PHP-FPM"
echo "        location ~* \.php$ {"
echo "                root /usr/share/nginx/html;"
echo "                include /etc/nginx/fastcgi.conf;"
echo "                fastcgi_pass  127.0.0.1:9000;"
echo "                fastcgi_index index.php;"
echo "                fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;"
echo "        }"
echo "At /etc/php7/php-fpm.d/www.conf change these settings:"
echo "user = nginx"
echo "group = nginx"
echo "listen = 9000"
echo "listen.owner = nginx"
echo "listen.group = nginx"     
echo "listen.mode = 0660"
echo "listen.allowed_clients = 127.0.0.1"

echo $"\n\nInstalling php7 for Alpine..."
apk add curl php7 php7-mbstring php7-openssl php7-phar php7-json php7-zlib php7-zip
/usr/bin/php7 -v
ln -s /usr/bin/php7 /usr/bin/php

echo $"\n\nAvoiding trouble with composer when calling php..."
curl -sS https://getcomposer.org/installer | php7
cp composer.phar /usr/local/bin/composer
composer -V

echo $"\n\n****************************"
echo "Some manual commands"
echo "****************************"
echo "- to stop nginx:"
echo "nginx -s stop"

echo $"\n- to start nginx" 
echo "nginx"

echo $"\n- to start nginx with no daemon (in docker run...)" 
echo "nginx -g 'daemon off;'"

echo $"\n- to reload nginx : "
echo "nginx -s reload"

echo $"\n- to start php fpm:"
echo "	php-fpm7"

echo $"\n- to run php7 console: "
echo "/usr/bin/php7 or php"

echo $"\n- to kill all php-fpm7 processes:"
echo "	kill $(ps -o pid,comm | grep nginx | awk '{print $1}')"

echo $"\n- to start php-fpm7:"
echo "php-fpm7"
