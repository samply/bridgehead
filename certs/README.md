Drop in directory for certificates.
You can generate the necessary certs with:

``` shell
openssl req -x509 -newkey rsa:4096 -keyout certs/traefik.key -out certs/treafik.crt -days 365
```
