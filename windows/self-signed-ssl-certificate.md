# Generate self signed SSL certificate

> Enter `winpty openssl ...` if you are on gitbash

## generate the certificate cert.pem
```
openssl req -x509 -newkey rsa:2048 -keyout keytmp.pem -out cert.pem -days 365
```

## generate the private key file key.pem
```
openssl rsa -in keytmp.pem -out key.pem
```

