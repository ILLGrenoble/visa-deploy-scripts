## Visa Deploy Scripts

### Description

This project provides a skeleton deployment script for VISA. You will have to modify several parts of this to make it work at your site, such as:

- complete environment variables
- SSL certificates
- VISA Accounts attribute provider

VISA is deployed using `docker-compose` and a script is provided to wrap this and to ensure that all necessary files are provided.

For a more details description of the VISA deployment, please refer to [the official VISA documentation](https://visa.readthedocs.io/en/latest/).

### Configuration

The minimum steps before launching the app for the first time are :

- create a `provider.js` (the name can be different, see `--provider` to set it.)
- create nginx `certs` in nginx/certs (see `nginx/conf/nginx.conf`)
- configure all values in `example.env` (and pass it via `--envfile`)
- configure nginx.conf for documentation URL

### Usage

To launch VISA, you can use the following script to create and launch all containers:

```bash
./deploy.sh
```

Please fill the following parameters the first time you launch the script to allow `deploy.sh` to copy config files.
After the first use, you can omit them. Optionnaly you can use --restart to force recreation of all containers, and not just modified ones.

```
deploy.sh [options]
Options and equivalent environment variables:"
  -e   or --envfile <path>         VISA_ENV_FILE          set the environment file location
  -n   or --nginx-conf <path>      VISA_NGINX_CONF        set the nginx configuration file location (optional)
  -sk  or --ssl-key <path>         VISA_SSL_KEY           set the SSL key location
  -sc  or --ssl-crt <path>         VISA_SSL_CRT           set the SSL certificate location
  -p   or --provider                                      set the account attribute provider file location
  -r   or --restart                                       restart all the docker images
```

## Optional parts

- create a micro service for security groups, and add it to docker-compose.yml