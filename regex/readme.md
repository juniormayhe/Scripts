# Regular expressions

## Colombian any number or license plate number 99999 or ABC123
```
^[0-9]+$|^[A-Z]{3}[0-9]{3}$
```

## Range of decimal numbers 1,2,3,4.55555,...
```
([0-9]+(?:\.[0-9]+)?|0?\.[1-9]+)
```
