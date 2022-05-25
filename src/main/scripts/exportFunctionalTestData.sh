#!/usr/bin/env bash
if [ -z "$1" ]
  then
    echo "No data set name argument supplied"
    exit 1
fi

export DATABASE_NAME=ecodata-test
export DATA_PATH=test/functional/resources/$1

# Configure the ecodata-test database to be how the functional tests expect it.
mongoexport --db $DATABASE_NAME --collection organisation --out $DATA_PATH/organisation.json
mongoexport --db $DATABASE_NAME --collection userPermission --out $DATA_PATH/userPermission.json
mongoexport --db $DATABASE_NAME --collection project --out $DATA_PATH/project.json
