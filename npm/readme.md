# Make npm start accept export in gitbash
```bash
#!/bin/bash
export PUBLIC_URL=
export PORT=443
export HTTPS=true
export SSL_CRT_FILE=cert.pem
export SSL_KEY_FILE=key.pem

#npx react-scripts start
```
then in packages.json
```json
  "scripts": {
    "start": "start.sh",
    "build": "react-scripts build",
    "git": "cd ../ && pwd && git add . && git commit -m 'update' && git push && cd front-end"
  },
```
