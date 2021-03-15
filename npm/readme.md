# Make npm start accept export in gitbash
in Windows environment the export command is not recognized. 

In Windows we can either use:

- `SET var=value` on Command Prompt 
- `$var=value` in Powershell, or 
- `export var=value` in gitbash. 

Facts:

- we can use gitbash to run export directly in terminal, and it works correctly
- we cannot use gitbash to run `npm start` with export command set in package.json `"scripts": { "export var=value ..." }`

To overcome limitation we can create a bash script to be executed by `npm start`, and export commands should work fine in gitbash.

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
  },
```
