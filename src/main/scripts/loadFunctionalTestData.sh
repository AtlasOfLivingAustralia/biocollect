#!/usr/bin/env bash
echo "This script should be run from the project root directory"
if [ -z "$1" ]
  then
    echo "No data set name argument supplied"
    exit 1
fi

export DATABASE_NAME=ecodata-test
export DATA_PATH=$1

# Configure the ecodata-test database to be how the functional tests expect it.
mongo $DATABASE_NAME --eval "db.dropDatabase()"

# Configure the ecodata-test database to be how the functional tests expect it.
mongoimport --db $DATABASE_NAME --collection organisation --file $DATA_PATH/organisation.json
mongoimport --db $DATABASE_NAME --collection project --file $DATA_PATH/project.json
mongoimport --db $DATABASE_NAME --collection userPermission --file $DATA_PATH/userPermission.json
mongoimport --db $DATABASE_NAME --collection setting --file $DATA_PATH/setting.json
