# Add self signed certificate for react app

First [generate the cert and private key](https://github.com/juniormayhe/Scripts/blob/41581aaec7e9248980669af793dfed0387176dbf/windows/self-signed-ssl-certificate.md)

In packages.json scripts, add your exports
```
"start": "export HTTPS=true&&SSL_CRT_FILE=cert.pem&&SSL_KEY_FILE=key.pem react-scripts start"
```
To make exports work in gitbash under Windows, [go here](https://github.com/juniormayhe/Scripts/tree/master/npm#make-npm-start-accept-export-in-gitbash)
