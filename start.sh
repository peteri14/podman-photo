#!/bin/bash

source ./env

if [ $# -eq 0 ]; then
  echo "ERROR: Version number must be specified"
  exit 1
fi

if [ ! -d "${DIR_APP}" ]; then
  echo "ERROR: Application directory (${DIR_APP}) does not exist"
  exit 1
fi

context=$(stat -c %C "${DIR_APP}" | cut -d: -f3)
if [ "x${context}" != "xcontainer_file_t" ]; then
  echo "ERROR: SELinux context for directory (${DIR_APP}) is wrong: ${context}"
  exit 1
fi

if [ ! -d "${DIR_DB}" ]; then
  echo "ERROR: Database directory (${DIR_DB}) does not exist"
  exit 1
fi

context=$(stat -c %C "${DIR_DB}" | cut -d: -f3)
if [ "x${context}" != "xcontainer_file_t" ]; then
  echo "ERROR: SELinux context for directory (${DIR_DB}) is wrong: ${context}"
  exit 1
fi


podman run -d --ip=${IP_PHP} -v ${DIR_APP}:/var/www/html localhost/php:$1
if [ $? -ne 0 ]; then
  echo "ERROR: There was an error running php container"
  exit 1
fi

podman run -d --ip=${IP_WEB} -p 80:80 -v ${DIR_APP}:/var/www/html localhost/www:$1
if [ $? -ne 0 ]; then
  echo "ERROR: There was an error running www container"
  exit 1
fi

podman run -d --ip=${IP_DB} \
-e MYSQL_USER=${DB_USER} \
-e MYSQL_PASSWORD=${DB_PASSWORD} \
-e MYSQL_DATABASE=${DB_NAME} \
-e MYSQL_DEFAULT_AUTHENTICATION_PLUGIN=mysql_native_password \
-v ${DIR_DB}:/var/lib/mysql/data \
registry.access.redhat.com/rhscl/mysql-80-rhel7

if [ $? -ne 0 ]; then
  echo "ERROR: There was an error running db container"
  exit 1
fi

echo "Please wait at least 60 sec for MySQL to initialize the database"

for i in $(seq 1 60); do
  echo -n "."
  sleep 1
done

echo -e "\nSuccess\n"

