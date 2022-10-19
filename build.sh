#!/bin/bash

source ./env

OFF='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'

if [ $# -eq 0 ]; then
  echo -e "${RED}ERROR: Version number must be specified${OFF}"
  exit 1
fi

function create_dir {
  local pattern
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi

  grep -q "$1" /etc/selinux/targeted/contexts/files/file_contexts.local
  if [ $? -ne 0 ]; then
    pattern="$1(./*)?"
    semanage fcontext -a -t container_file_t ${pattern}
  fi
  restorecon -R $1

  # we have to set the ownership for the MySQL directory !!!!!
  if [ "x$2" = "xmysql" ]; then
    chown -R 27:27 $1
  fi
}

# create external directories
echo -e "${GREEN}Creating application directory ...${OFF}"
create_dir ${DIR_APP} "app"
echo -e "${GREEN}Creating database directory ...${OFF}"
create_dir ${DIR_DB} "mysql"

# copy the code
echo -e "${GREEN}Copying code ...${OFF}"
cp -r code/* ${DIR_APP}
mkdir -p ${DIR_APP}/uploads
chmod a+w ${DIR_APP}/uploads

# configure the code
echo -e "${GREEN}Configuring code ...${OFF}"
sed -e "s/\$hostname.*=.*/\$hostname = \"${IP_DB}\";/" \
    -e "s/\$username.*=.*/\$username = \"${DB_USER}\";/" \
    -e "s/\$password.*=.*/\$password = \"${DB_PASSWORD}\";/" \
    -e "s/\$databasename.*=.*/\$databasename = \"${DB_NAME}\";/" -i ${DIR_APP}/database.php

# configure the Dockerfile for the php container
echo -e "${GREEN}Configuring php container ...${OFF}"
sed -e "s/listen.allowed_clients.*/listen.allowed_clients = ${IP_WEB}/" -i php/www.conf

# create the php container
echo -e "${GREEN}Building php container ...${OFF}"
podman build -t php:$1 -f Dockerfile-php

if [ $? -ne 0 ]; then
  echo -e "${RED}ERROR: There was an error building php container${OFF}"
  exit 1
fi

# configure the Dockerfile for the web container
echo -e "${GREEN}Configuring www container ...${OFF}"
sed -e "s#SetHandler \"proxy:fcgi://.*\"#SetHandler \"proxy:fcgi://${IP_PHP}:9000\"#" -i www/php.conf

# create the web container
echo -e "${GREEN}Building www container ...${OFF}"
podman build -t www:$1 -f Dockerfile-www

if [ $? -ne 0 ]; then
  echo -e "${RED}ERROR: There was an error building www container${OFF}"
  exit 1
fi

echo -e "${GREEN}-------------------${OFF}"
echo -e "${GREEN}Successfull building${OFF}"
echo -e "${GREEN}Version: '$1'${OFF}"

exit 0



