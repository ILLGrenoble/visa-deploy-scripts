#!/bin/bash

usage() {
	echo "deploy.sh [options]"
	echo
	echo "Options and equivalent environment variables:"
	echo "  -e   or --envfile <path>         VISA_ENV_FILE          set the environment file location"
	echo "  -n   or --nginx-conf <path>      VISA_NGINX_CONF        set the nginx configuration file location (optional)"
	echo "  -sk  or --ssl-key <path>         VISA_SSL_KEY           set the SSL key location"
	echo "  -sc  or --ssl-crt <path>         VISA_SSL_CRT           set the SSL certificate location"
	echo "  -p   or --provider                                      set the account provider file location"
	echo "  -r   or --restart                                       restart all the docker images"
}

# Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	-e|--env-file)
	VISA_ENV_FILE="$2"
	shift
	shift
	;;

	-n|--nginx-conf)
	VISA_NGINX_CONF="$2"
	shift
	shift
	;;

	-sk|--ssl-key)
	VISA_SSL_KEY="$2"
	shift
	shift
	;;

	-sc|--ssl-crt)
	VISA_SSL_CRT="$2"
	shift
	shift
	;;

	-r|--restart)
	RESTART_DOCKER_IMAGES=1
	shift
	;;

	-p|--provider)
	VISA_ACCOUNT_PROVIDER_FILE="$2"
	shift
	shift
	;;

	*)
	break
	;;
esac
done

SSL_CRT_LOCATION=nginx/certs/web.crt
SSL_KEY_LOCATION=nginx/certs/web.key
NGINX_CONF_LOCATION=nginx/conf/nginx.conf

# Verify SSL key/certificate parameters
if [[ ( ! -z "$VISA_SSL_KEY" || -f "$SSL_KEY_LOCATION" ) && ( ! -z "$VISA_SSL_CRT" || -f "$SSL_CRT_LOCATION" ) ]]; then
  # Verify files exist
	if [[ ! -z "$VISA_SSL_KEY" && ! -f "$VISA_SSL_KEY" ]]; then
		echo "SSL key not found at $VISA_SSL_KEY"
		exit
	fi
	if [[ ! -z "$VISA_SSL_CRT" && ! -f "$VISA_SSL_CRT" ]]; then
		echo "SSL certficate not found at $VISA_SSL_CRT"
		exit
	fi
else
	echo "You need to specify the SSL key/crt locations"
	usage
	exit
fi

# Verify env file parameter
if [[ ! -z "$VISA_ENV_FILE" || -f .env ]]; then
  # Verify files exist
	if [[ ! -z "$VISA_ENV_FILE" && ! -f "$VISA_ENV_FILE" ]]; then
		echo "Environment file not found at $VISA_ENV_FILE"
		exit
	fi
else
	echo "You need to specify the environment file location"
	usage
	exit
fi

# Verify nginx conf file
if [ ! -z "$VISA_NGINX_CONF" ]; then
  # Verify files exist
	if [ ! -f "$VISA_NGINX_CONF" ]; then
		echo "nginx configuration file not found at $VISA_NGINX_CONF"
		exit
	fi
fi

# Verify visa accounts provider file
if [ ! -z "$VISA_ACCOUNT_PROVIDER_FILE" ]; then
  # Verify files exist
	if [ ! -f "$VISA_ACCOUNT_PROVIDER_FILE" ]; then
		echo "account provider file not found at $VISA_NGINX_CONF"
		exit
	fi
else
	echo "You need to specify the account provider file location"
	usage
	exit
fi

# copy SSL key/certificate
if [ ! -z "$VISA_SSL_KEY" ]; then
	echo "Copying web.key from $VISA_SSL_KEY"
	cp "$VISA_SSL_KEY" "$SSL_KEY_LOCATION"
fi
if [ ! -z "$VISA_SSL_CRT" ]; then
	echo "Copying web.crt from $VISA_SSL_CRT"
	cp "$VISA_SSL_CRT" "$SSL_CRT_LOCATION"
fi

# Copy the env file
if [ ! -z "$VISA_ENV_FILE" ]; then
	echo "Copying .env file from $VISA_ENV_FILE"
	cp "$VISA_ENV_FILE" .env
fi

# Copy the provider file
if [ ! -z "$VISA_ACCOUNT_PROVIDER_FILE" ]; then
	echo "Copying account-provider.js file from $VISA_ACCOUNT_PROVIDER_FILE"
	cp "$VISA_ACCOUNT_PROVIDER_FILE" providers/attribute-provider.js
fi

# Copy nginx.conf
if [ ! -z "$VISA_NGINX_CONF" ]; then
  echo "Copying nginx.conf file from $VISA_NGINX_CONF"
	cp "$VISA_NGINX_CONF" "$NGINX_CONF_LOCATION"
elif [ ! -f "$NGINX_CONF_LOCATION" ]; then 
	# copy default nginx.conf
  echo "Copying default nginx.conf file"
	cp nginx/nginx.prod.conf "$NGINX_CONF_LOCATION"
fi

# Stop current containers if restart
if [ "$RESTART_DOCKER_IMAGES" == 1 ]; then
	echo "Restarting all docker images"
	docker-compose --env-file .env down
fi

# Pull latest images
docker-compose --env-file .env pull

# Run new containers
docker-compose --env-file .env up -d

# prune all unused images
echo "Pruning unused images"
docker image prune -a --force
