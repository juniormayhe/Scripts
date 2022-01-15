Redirects https://support.streamspell.com to https://www.streamspell.com/support

# Turn on rewrite
```
sudo a2enmod rewrite
```

# Edit htaccess

nano /var/www/html/.htaccess
```
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

RewriteCond %{HTTP_HOST} ^support.streamspell.com$ [NC]
RewriteRule ^(.*)$ https://www.streamspell.com/support [R=301,L]
</IfModule>
```

# Reload apache

```
sudo systemctl restart apache2
```
