#!/bin/bash -v
echo "This script should be run from the project root directory"
if [ -z "$1" ]
  then
    echo "No data set name argument supplied"
    exit 1
fi

echo "$2" > /tmp/blah
AUTH_OPTS=
if [ "$2" ]
  then
    AUTH_OPTS="-u $2 -p $3"
    echo "mongo $DATABASE_NAME $AUTH_OPTS --eval " >>  /tmp/blah
fi

DATABASE_NAME=ecodata-functional-test
DATA_PATH=$1

cd $DATA_PATH
echo $PWD

mongo $DATABASE_NAME $AUTH_OPTS --eval "db.dropDatabase()"
mongo $DATABASE_NAME $AUTH_OPTS loadDataSet.js


