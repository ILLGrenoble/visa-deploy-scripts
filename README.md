## How to use Visa Deploy Scripts

### Configuration

- create pem files for `VISA_VDI_SIGNATURE_*` in `pam/`
- create `provider.js` in providers/
- create nginx `certs` in nginx/certs (see `nginx/conf/nginx.conf`)
- configure all values in `.env`

### Usage

```
./deploy.sh
```

```
deploy.sh [options]
Options and equivalent environment variables:"
  -e   or --envfile <path>         VISA_ENV_FILE          set the environment file location
  -n   or --nginx-conf <path>      VISA_NGINX_CONF        set the nginx configuration file location (optional)
  -sk  or --ssl-key <path>         VISA_SSL_KEY           set the SSL key location
  -sc  or --ssl-crt <path>         VISA_SSL_CRT           set the SSL certificate location
  -ppr or --pam-private <path>     VISA_PAM_PRIVATE       set the PAM module private key location
  -ppu or --pam-public <path>      VISA_PAM_PUBLIC        set the PAM module public key location
  -r   or --restart                                       restart all the docker images
```